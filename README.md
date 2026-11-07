# IBM i SQL Toolkit

Ready-to-run SQL for the questions an IBM i developer or administrator gets asked every week:
*is the system healthy, who has too much authority, why is this query slow?* Everything uses
**IBM i Services** (`QSYS2` views and table functions) and the Db2 for i catalog, so there are no
programs to install. Paste a script into *Run SQL Scripts* in IBM i Access Client Solutions, or run it
from any SQL client, and replace `MYLIB` with your library.

Every script was run on [PUB400.COM](https://pub400.com) (IBM i 7.5) with a normal user profile,
without special authorities. The output is in [`samples/`](samples). Where a script needs more authority
than that profile has, the sample shows the real error, and the script header says which authority it
needs. All table names and data in the RCAC demo are fictional. This is a sample project.

## Health

| Script | Question it answers | Needs |
|---|---|---|
| [01 system overview](health/01-system-overview.sql) | CPU %, disk (ASP) used, memory, number of jobs, temporary storage, in one row | any user |
| [02 jobs waiting for reply](health/02-jobs-waiting-for-reply.sql) | Which jobs are stuck in `MSGW` waiting for an operator answer | `*JOBCTL` for all jobs |
| [03 top CPU jobs](health/03-top-cpu-jobs.sql) | The 10 active jobs using the most CPU | `*JOBCTL` for all jobs |
| [04 spool usage](health/04-spool-usage.sql) | Spooled files per user: count, pages, MB, oldest, older than 30 days | `*SPLCTL` for all users |
| [05 object locks](health/05-object-locks.sql) | Who is locking the objects in a library (before `CHGPF`, a restore, a nightly run) | `*JOBCTL` for other users' jobs |
| [06 largest objects](health/06-largest-objects.sql) | The 15 biggest objects in a library and when they were last used | `*USE` on the objects |

## Security

| Script | Question it answers | Needs |
|---|---|---|
| [01 powerful profiles](security/01-powerful-profiles.sql) | Enabled profiles with `*ALLOBJ`, `*SECADM`, `*AUDIT`, `*SERVICE` | `*SECADM` to see all profiles |
| [02 weak profiles](security/02-weak-profiles.sql) | Default password (password = user name), unused 90 days, password never expires | `*SECADM` (+ `*ALLOBJ` for default password) |
| [03 *PUBLIC authority](security/03-public-authority.sql) | Objects that `*PUBLIC` can change or delete, and a summary of `*PUBLIC` settings | owner / `*OBJMGT` |
| [04 adopted authority](security/04-adopted-authority.sql) | Programs that run as their owner (`USRPRF(*OWNER)`), the owner's special authorities, and who may call them | any user |

## Performance

| Script | Question it answers | Needs |
|---|---|---|
| [01 index advisor](performance/01-index-advisor.sql) | Which indexes the optimizer (SQE) asked for, how often, and the `CREATE INDEX` to try | any user |
| [02 tables without index](performance/02-tables-without-index.sql) | Data tables with rows but no index, keyed LF, key or primary/unique constraint | any user |
| [03 reorg candidates](performance/03-reorg-candidates.sql) | Members with many deleted rows (space still allocated, full scans still read it) | any user |
| [04 plan cache top statements](performance/04-plan-cache-top-statements.sql) | The 10 most expensive SQL statements in the plan cache | `*JOBCTL` or `QIBM_DB_SQLADM` |

## Row and column access control (RCAC)

A fictional customer table where each user may only see the customers of their own sales region, and
phone numbers are masked unless the user belongs to the `SALESMGR` group.

| Script | What it does | Result on PUB400 |
|---|---|---|
| [01 setup tables](rcac/01-setup-tables.sql) | Customer table (5 rows, 3 regions) and a user-to-region table | runs |
| [02 permission and mask](rcac/02-permission-and-mask.sql) | `CREATE PERMISSION` (rows by region), `CREATE MASK` (phone), `ACTIVATE ROW/COLUMN ACCESS CONTROL` | `SQL0552` — needs `QIBM_DB_SECADM` |
| [03 secure view alternative](rcac/03-secure-view-alternative.sql) | The same rule as a view, for systems where you cannot use RCAC | runs: 2 of 5 rows, phone `XXX-XXX-0101` |
| [04 cleanup](rcac/04-cleanup.sql) | Drops the demo objects | runs |

Why RCAC is better than the view: the permission and the mask are part of the **table**, so every
interface gets the same rows — SQL, RPG native I/O, ODBC, Query/400, DFU — and even a profile with
`*ALLOBJ` sees masked data unless the rule lets it through. A view only protects the people who use the
view. RCAC is also separated from the data owner: only a user with the `QIBM_DB_SECADM` function usage
can create or change the rules, which is what auditors want to see.

## What the samples show

Real findings from running the toolkit on a shared system with a normal profile:

- **A job waiting for a reply.** `health/02` found a remote command server job (`QZRCSRVS`) of this user in
  `MSGW` — the kind of job that blocks a batch stream until someone answers it.
- **Optimizer advice.** `performance/01` shows that the optimizer asked 5 times for an index on
  `STOCK_BALANCE (STWHS, STITEM)` and generates the `CREATE INDEX` statement.
- **Deleted rows.** `performance/03` lists files where half the space is deleted rows — a `RGZPFM` candidate.
- **No public access.** `security/03` shows all 81 objects in the library are `*PUBLIC *EXCLUDE`.
- **Adopted authority.** `security/04` lists the two programs compiled with `USRPRF(*OWNER)`, both not
  callable by `*PUBLIC`.
- **What a normal profile cannot see.** `security/01` returns nothing and `USER_INFO` shows only the user's
  own profile: the services respect authority, so an empty result can mean "not allowed to see" rather
  than "nothing found". The plan cache dump fails with `CPF43A3`, RCAC with `SQL0552`.

## Notes

- Server jobs such as `QZDASOINIT` (ODBC/JDBC) run as `QUSER`; filter on `AUTHORIZATION_NAME`, not
  `JOB_USER`, to find the jobs of a user.
- `QSYS2.USER_INFO` and the other services return only what the caller is authorized to see — run the
  security scripts with a security officer profile for a real audit.
- `OUTPUT_QUEUE_ENTRIES_BASIC` and `OBJECT_LOCK_INFO` can read the whole system; keep the filters on busy systems.
