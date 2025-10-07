# Mendix application to test the unique key issue

This error happens randomly and only in a clustered Mendix app. It’s unclear whether it’s a regression in 10.24.8 or the bug existed earlier.

To reproduce locally make sure you have a working docker executable and run `run-docker.bat` in the project folder. It is expected to build and run the app in a local cluster. See `build-scripts/` for more information.

When clicking a “Save changes” action button and the new or edited object violates a Unique Validation Rule then the error pop-up shows a generic error instead of the rule message.

Expected:

`This combination of Task and CopyEditing Categories is alredy used`

Actual:

`An error occurred, please contact your system administrator.`

Prerequisites:

* The app security mode is “Production” (user is required to login and Mendix checks the access rules of entities)
* After logging in, all web requests except “Save changes” which is the last one are served by one node
* The “Save changes” web request is served by another node.
* The changes to save come from a form page where the main object and at least one referenced new object exist

The stack trace suggests that after the JDBC executeUpdate call fails with a “duplicate key” message, Mendix calls `getInternationalizedString` to get a translated validation message, but this fails inside `getLanguage` because the current transaction/savepoint is invalid.

The reason why it only happens in a cluster is because `getLanguage` only queries the DB if the "System.User_Language" `MendixObjectMemberImpl` is not initialized yet. If “Save Changes” is the first web request to the current app instance (in particular, a web page structure with captions haven’t been served by it) it means that it’s the first attempt to translate a text, the User object cached in memory for the current session is not fully initialized, and since the current transaction/savepoint is invalid, the SQL to retrieve System.User_Language fails.

It's unclear why the second object on the form page is necessary to reproduce the error.

Here’s an extract from the Stack Trace:

```
Caused by: 
org.postgresql.util.PSQLException: ERROR: current transaction is aborted, commands ignored until end of transaction block
...
	at com.mendix.basis.objectmanagement.SchemeManagerImpl.retrieveAndSetObjectAccess(SchemeManagerImpl.scala:177)
	at com.mendix.basis.objectmanagement.MendixObjectMemberImpl.checkAccessRetrieved(MendixObjectMemberImpl.java:189)
	at com.mendix.basis.objectmanagement.MendixObjectMemberImpl.hasReadAccess(MendixObjectMemberImpl.java:198)
	at com.mendix.basis.objectmanagement.MendixObjectMemberImpl.checkReadAccess(MendixObjectMemberImpl.java:165)
	at com.mendix.basis.objectmanagement.MendixObjectMemberImpl.getValue(MendixObjectMemberImpl.java:215)
	at com.mendix.basis.objectmanagement.MendixObjectImpl.getValue(MendixObjectImpl.java:275)
	at com.mendix.implicits.package$MendixObjectOps$.getTyped$extension(package.scala:30)
	at com.mendix.implicits.package$MendixObjectOps$.getTyped$extension(package.scala:37)
	at com.mendix.basis.systemmodule.internal.UserManagerImpl.$anonfun$getLanguage$1(UserManagerImpl.scala:20)
	at scala.Option.flatMap(Option.scala:283)
	at com.mendix.basis.systemmodule.internal.UserManagerImpl.getLanguage(UserManagerImpl.scala:20)
	at com.mendix.modelstorage.i18n.I18NProcessor.getInternationalizedString(I18NProcessor.scala:64)
	at com.mendix.basis.component.SessionCore.getInternationalizedStringVarargs(SessionCore.scala:105)
	at com.mendix.basis.component.SessionCore.getInternationalizedStringVarargs$(SessionCore.scala:103)
	at com.mendix.basis.component.InternalCore.getInternationalizedStringVarargs(InternalCore.scala:22)
	at com.mendix.basis.component.InternalCoreVarargs.getInternationalizedString(InternalCoreVarargs.java:41)
	at com.mendix.basis.action.user.CommitAction.createUserException$1(CommitAction.scala:127)
...
Caused by: 
org.postgresql.util.PSQLException: ERROR: duplicate key value violates unique constraint "uniq_bookproductionutils$turnaroundtimex__taskandcopyeds"
  Detail: Key (_taskandcopyeds)=(352969620795163824;,*,;) already exists.
...
	at com.mendix.basis.action.user.CommitAction.commit(CommitAction.scala:160)
```
