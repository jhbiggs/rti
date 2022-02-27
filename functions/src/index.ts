import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { auth } from "firebase-admin";
import { UserRecord } from "firebase-functions/v1/auth";

admin.initializeApp();
admin.auth();
// const db = admin.firestore();

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
    studentCount: 0,
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

exports.setUpGroups = functions.firestore.document('assignments/{docId}').onCreate(async (change, context) => {
  //need the RTI assignments with subject name
  

  // let subjectSet = new Set<string>();
  // var teacherSubjects = [];
  var teachers:UserRecord[] = [];
  // var teachers = [];
  //need the teachers with subject name
  const returnValue = auth().listUsers(1000);
         /* find the next teacher with this subject with the fewest number of students
        and assign this student to the teacher.*/
        
        console.log('going into teacher assignment')
        let studentSubject = change.data()['subject'];
   teachers =  (await returnValue).users.filter(thisUser => thisUser.customClaims 
    && thisUser.customClaims['subject'] != null && thisUser.customClaims['subject']==studentSubject
    );
    teachers.sort((userA, userB) => userA.customClaims!['studentCount'] - userB.customClaims!['studentCount'])
        // subjectSet.forEach(subject => console.log(subject));

        if (teachers[0] != null){
          console.log(`teacher is ${teachers[0].displayName!}`)
          if (change.data()['teacher'] == null || change.data()['teacher'] == "null"){
            change.ref.update({
              teacher: teachers[0].displayName! as string
              }).catch(e => console.log(e))
            }
        /*increment the teacher student count custom claim*/
        teachers[0].customClaims!['studentCount']++;
        } else {
          console.log('sorry, there is no teacher with that subject for the assignment')
        }

       

});
//TODO: add function to allow admin to set max number of students per group
// # sourceMappingURL=index.js.map
