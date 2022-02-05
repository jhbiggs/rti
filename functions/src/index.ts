import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { auth } from "firebase-admin";

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

exports.setUpGroups = functions.https.onCall(async (data, context) => {
  //need the RTI assignments with subject name

  //need the teachers with subject name
  const returnValue = await auth().listUsers(1000);
  
  var teacherSubjects = returnValue.users.flatMap(
    eachUser => {
      if (eachUser.customClaims && eachUser.customClaims['subject'] != null){
      return eachUser.customClaims!['subject']
      }
    })
    //here's a nifty trick I found that filters out "undefined" objects by 
    //doing an existence check
    .filter((item)=> item);

    //get a list of unique subjects within teacherSubjects
    let subjectSet = new Set();
    teacherSubjects.forEach(subject => subjectSet.add(subject));
    teacherSubjects.forEach(subject => console.log(subject));
    //now create a map with a subject as key and counter as value
    let subjectCountMap = new Map();
    //set the initial count to zero on each subject
    subjectSet.forEach(subject => subjectCountMap.set(subject, 0));
    //now iterate over subjects
    teacherSubjects.forEach(subject => {
      //get the current count on this subject
      var count = subjectCountMap.get(subject);
      //increment the count
      subjectCountMap.set(subject, ++count);
    })
    console.log(subjectCountMap.values());

  //need max number of students per group
  // const maxStudents = 30;

  //get student RTI assignment batch by subject
  subjectSet.forEach(async assSubject => {
    const assignmentsBySubject = db.collection('assignmentsBySubject')
    .doc(assSubject as string)
    .collection('assignments');
    console.log(`hello ${assSubject}`);
    (await assignmentsBySubject.get()).docs.forEach(doc=> {
      doc.ref.update({
        subject: assSubject,
        teacher: "Ms. Z."
      })
    })
    });
  
  


  //dole out students to each group one at a time,
  // to each teacher like dealing cards

  //first get the individual subject collections
  
  //stop dealing when limit is reached per teacher and
  //do something (a toast?) to let someone
  //know there was a failure

});
//TODO: add function to allow admin to set max number of students per group
// # sourceMappingURL=index.js.map
