import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { auth } from "firebase-admin";
import { UserRecord } from "firebase-functions/v1/auth";

admin.initializeApp();
admin.auth();
const db = admin.firestore();

// exports.myFunction = functions.firestore
//   .document('assignments/{docId}')
//   .onWrite(async (change, context) => {

//     // The subjects array needs scope here 
//     // upon which to build collections later.
//     var subjects: string[] = []; 
//     // var queryValues: string[] = [];

//     //get the assignments ordered by subject, then
//     //add distinct subject headings to an array for processing
//     await db.collection('assignments').orderBy('subject').get().then(
//       value => {
        
//         value.docs.forEach(doc =>{
//           const thisSubject = doc.data()['subject'];
//           //we're looking for distinct subjects on which to build sub-collections
//           if (!subjects.includes(thisSubject)){
//             subjects.push(thisSubject);
//           };
          
//       });
//       console.log(subjects);
//     });
//     for (var subject of subjects){

//       await db.collection('assignmentsBySubject').doc(subject).delete();
//       var batch = db.batch();
//       await db.collection('assignments').where('subject', '==', subject)
//       .get()
//       .then(queryDoc => {
//         queryDoc.docs.forEach(assignment => {
//           var docRef = db.collection("assignmentsBySubject")
//           .doc(subject)
//           .collection('assignments')
//           .doc(); //automatically generate unique id
//           batch.set(docRef, assignment.data());
//           });
//           batch.commit();
//         })
//         .catch(e => console.log(e));

      
//         };
//     });

  
// add administrator function
exports.addAdmin = functions.https.onCall((data, context) => {
  admin.auth().setCustomUserClaims((context.auth!.uid), {admin: true});
  console.log(`Your data.uid was: ${context.auth!.uid}`);
  admin.auth().getUser(context.auth!.uid).then(async (user) => {
    console.log(`YOUR USER EMAIL WAS: ${user.email}`);
    await grantAdminRole(user);
    return {
      result: `Request fulfilled! ${user.email} is now admin.`,
    };
  }).catch((reason: any) => console.log(`REJECTION REASON WAS: ${reason}`));
});

exports.addTeacher = functions.https.onCall((data, context) => {
  console.log(`Your data.uid was: ${context.auth!.uid}`);
  admin.auth().getUser(context.auth!.uid).then(async (user) => {
    console.log(`YOUR USER EMAIL WAS: ${user.email}`);
    await grantTeacherRole(user);
    return {
      result: `Request fulfilled! ${user.email} is now a moderator.`,
    };
  }).catch((reason: any) => console.log(`REJECTION REASON WAS: ${reason}`));
});

exports.addSubject = functions.https.onCall((data, context) => {
  console.log(`Your data.uid was: ${context.auth!.uid}`);
  admin.auth().getUser(context.auth!.uid).then(async (user) => {
    console.log(`YOUR USER EMAIL WAS: ${user.email}`);
    console.log(`YOUR PARAMETER SUBJECT WAS: ${data.subject}`);
    await grantSubject(user, data.subject);
    return {
      result: `Request fulfilled! ${user.email} now has a subject.`,
    };
  }).catch((reason: any) => console.log(`REJECTION REASON WAS: ${reason}`));
});

/**
 * @param {admin.auth.UserRecord} user the user's email
 * @return {void}
*/
async function grantAdminRole(user:admin.auth.UserRecord) {
  if (user.customClaims && user.customClaims.admin === true) {
    console.log("custom claims function true");
    return;
  }
  console.log("custom claims not set, setting now...");

  return admin.auth().setCustomUserClaims(user.uid, {
    "admin": true,
  });
}
/**
 * @param {admin.auth.UserRecord} user the teacher's email
 * @return {void}
 */
async function grantTeacherRole(user:admin.auth.UserRecord) {
  if (user.customClaims && user.customClaims.teacher === true) {
    console.log("custom claims function true");
    return;
  }
  console.log("custom claims not set, setting now...");
  return admin.auth().setCustomUserClaims(user.uid, {
    "teacher": true,
  });
}

/**
 * @param {admin.auth.UserRecord} user the teacher's email
 * @param {string} subject the intended subject to be granted
 * @return {void}
 */
async function grantSubject(user:admin.auth.UserRecord, subject:string) {
  if (user.customClaims && user.customClaims.subject === subject) {
    console.log("teacher already has subject assigned");
    return;
  }
  console.log("teacher doesn't have this subject assigned, assigning now...");

  return admin.auth().setCustomUserClaims(user.uid, {
    subject: subject,
    teacher: true,
  });
}

exports.listAllUsers = functions.https.onCall((data, context)=>{
  // List batch of users, 1000 at a time.
  const returnValue = auth().listUsers(1000);
  returnValue
    .then((listUsersResult) => {
      listUsersResult.users.forEach((userRecord) => {
        console.log('user', userRecord.toJSON());
      });
      if (listUsersResult.pageToken) {
        // List next batch of users.
        // listAllUsers(listUsersResult.pageToken);
      }
    })
    .catch((error) => {
      console.log('Error listing users:', error);
    });
    return returnValue;
});

exports.setUpGroups = functions.firestore.document('assignments/{docId}').onWrite(async (change, context) => {
  //need the RTI assignments with subject name
  

  let subjectSet = new Set<string>();
  var teacherSubjects = [];
  var teachers:UserRecord[] = [];
  // var teachers = [];
  //need the teachers with subject name
  const returnValue = auth().listUsers(1000);
  returnValue
    .then((listUsersResult) => {
      if (listUsersResult.pageToken) {
        // List next batch of users.
        // listAllUsers(listUsersResult.pageToken);
      };
      teacherSubjects = listUsersResult.users.flatMap(
        eachUser => {
          if (eachUser.customClaims 
            && eachUser.customClaims['subject'] != null){
          return eachUser.customClaims!['subject']
          }
        })
        //here's a nifty trick I found that filters out "undefined" objects by 
        //doing an existence check
        .filter((item)=> item);
        console.log(`your subjects are ${teacherSubjects}`);
    
        //get a list of unique subjects within teacherSubjects
        teacherSubjects.forEach(subject => {
          if (!subjectSet.has(subject)){
            subjectSet.add(subject);
          }
        });
    
   teachers = listUsersResult.users.filter(thisUser => thisUser.customClaims 
    && thisUser.customClaims['subject']
    );
        subjectSet.forEach(subject => console.log(subject));
  /*enclose this process in a teacher-cycling block that iterates
  over the list of teachers with the same subject, assigning one 
  by one until the list is complete. */
  subjectSet.forEach(async assSubject => {
    let teachersForSubject = teachers.filter(teacher => 
      teacher.customClaims!['subject'] == assSubject as string)
      .filter(item=>item);
    let numberOfTeachersForSubject = teachersForSubject.length;
    teachersForSubject.forEach(teacher=>console.log(`your teacher's subject is
      ${teacher.customClaims!['subject']}`))
    var index = 0;
    console.log(`There are ${numberOfTeachersForSubject} teachers for 
      ${assSubject}`);

    //get student RTI assignment batch by subject
      const assignmentsBySubject = (await db.collection('assignments')
      .get()).docs
      .filter(document => document.data()['subject'] == assSubject)
      console.log(`hello ${assSubject}`);
      assignmentsBySubject.forEach(doc=> {
        doc.ref.update({
          teacher: teachersForSubject[index].displayName! as string
      }).catch(e => console.log(e))
      index++;
      if (index == numberOfTeachersForSubject){
        index = 0;
      }
      });
    })

}).catch(e=> console.log(e))

    // .catch((error) => {
    //   console.log('Error listing users:', error);
    // });
  


    //now create a map with a subject as key and counter as value
    let subjectMap = new Map();
    
    // set the initial map of subjects with an empty array.  The 
    // array will hold a list of teacher users for each subject.
    subjectSet.forEach(subject => subjectMap.set(subject, []));

    //now iterate over subjects

  //need max number of students per group
  // const maxStudents = 30;

  
  


  //dole out students to each group one at a time,
  // to each teacher like dealing cards

  //first get the individual subject collections
  
  //stop dealing when limit is reached per teacher and
  //do something (a toast?) to let someone
  //know there was a failure

});
//TODO: add function to allow admin to set max number of students per group
// # sourceMappingURL=index.js.map
