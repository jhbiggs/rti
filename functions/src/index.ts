import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {auth} from "firebase-admin";
// import {UserRecord} from "firebase-functions/v1/auth";

admin.initializeApp();
admin.auth();

// notification function

exports.notify = functions.https.onCall(async (data, context) => {
  const userId =  await admin.firestore()
  .collection("users")
  .doc(data.userId).get();

  admin.messaging().sendToDevice(
     userId.data()?.tokens,
    {
      notification: {
        title: "Hi " + data.name,
        body: "Welcome to our first cloud function",
        sound: "default"

      }
    }
  );
});

// add administrator function
exports.addAdmin = functions.https.onCall((data, context) => {
  admin.auth().createUser({
    "email": data.email,
    "displayName": data.name,
    "password": data.password,
  }).then(async (user) => {
    console.log(`YOUR USER EMAIL WAS: ${user.email}`);
    await grantAdminRole(user);
    return {
      result: `Request fulfilled! ${user.email} is now an admin.`,
    };
  }).catch((reason: any) => {
    console.log(`REJECTION REASON WAS: ${reason}`);
    return {
      result: `sorry,  ${context.auth?.token["displayName"]} can't add admin.`,
    };
  });
});

/**
 * @param {admin.auth.UserRecord} user the user"s email
 * @return {void}
*/
async function grantAdminRole(user:admin.auth.UserRecord) {
  if (user.customClaims && user.customClaims.admin === true) {
    console.log("custom claims already set");
    return;
  }
  console.log("custom claims not set, setting now...");

  return admin.auth().setCustomUserClaims(user.uid, {
    "role": "admin",
    "schoolCode": "chesterton",
  });
}

exports.addTeacher = functions.https.onCall((data, context) => {
  console.log("addTeacher function invoked.");
  console.log(`Your data school code was: ${data.schoolCode}`);
  console.log(`your context email is: ${context.auth?.token.email}`);
  // if (context.auth?.token["admin"]){
  admin.auth().createUser({
    "email": data.email,
    "displayName": data.name,
    "password": data.password,
  }).then(async (user) => {
    console.log(`YOUR USER EMAIL WAS: ${user.email}`);
    await grantTeacherRole(user, data.schoolCode, data.sheetID);
    await grantSubject(user, data.subject);
    return {
      result: `Request fulfilled! ${user.email} is now a teacher.`,
    };
  }).catch((reason: any) => {
    console.log(`REJECTION REASON WAS: ${reason}`);
    return {
      result: `sorry,  ${context.auth?.token["displayName"]} can't add admin.`,
    };
  });
  console.log("superUser");
// }
// else {
// if current user is not a superUser, they are not authorized to add admin...
// console.log("not a superUser, not authorized to add admin.");
//   return {
//     result: `sorry,  ${context.auth?.token["displayName"]} can't add admin.`,
//   };
// }
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
 * @param {admin.auth.UserRecord} user the teacher"s email
 * @param {string} schoolCode the unique code for the school district
 * @param {string} sheetID the google sheetID
 * @return {void}
 */
async function grantTeacherRole(
    user:admin.auth.UserRecord,
    schoolCode:string,
    sheetID:string) {
  if (user.customClaims && user.customClaims.role === "teacher") {
    console.log("user is already a teacher");
    return;
  }
  console.log("custom claims not set, setting now...");
  return admin.auth().setCustomUserClaims(user.uid, {
    "role": "teacher",
    "schoolCode": schoolCode,
    "sheetID": sheetID,
  });
}

/**
 * @param {admin.auth.UserRecord} user the teacher"s email
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
    studentCount: 0,
  });
}

exports.listAllUsers = functions.https.onCall((data, context)=>{
  // List batch of users, 1000 at a time.
  if (context.auth?.uid == null) {
    console.log("sorry, pal, you're not authenticated with us yet.");
  }
  const returnValue = auth().listUsers(1000);
  returnValue
      .then((listUsersResult) => {
        listUsersResult.users.forEach((userRecord) => {
          console.log("user", userRecord.toJSON());
        });
        if (listUsersResult.pageToken) {
        // List next batch of users.
        // listAllUsers(listUsersResult.pageToken);
        }
      })
      .catch((error) => {
        console.log("Error listing users:", error);
      });
  return returnValue;
});

// TODO: add function to allow admin to set max number of students per group
// # sourceMappingURL=index.js.map
