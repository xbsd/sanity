
/Common Settings: Logging, Init Functions, Others

\d .app

/Set Env. Vars
srcDir: {"/app/kdb/src"};
procFile: {raze x,"/test/comm/proctable.csv"};
qPath: {"/opt/q/l64/"}
qArgs: {"-s 16"}

.z.ts:{.Q.gc[]}
\t 2000


/Screen Process Utilities

createScreen: {system "screen -dm ",x} /Accepts String ("rxbgt")
getScreenCount: {system ("screen -ls | grep "),x," | wc -l"}
sendToScreen: {system raze "screen -S ",x," -p 0 -X stuff \"$(printf \\\\r)",y,"$(printf \\\\r)\""}
killScreen: {system "screen -ls | grep ",x," | cut -f1 -d'.' | sed 's/\\W//g' | xargs kill -9; screen -wipe;true"}
startCleanScreen: { killScreen x; createScreen x }

startShellProc:{
 strx: $[-11h~type x;string x;x];
 symx: $[-11h~type x;x;`$x];
 params:getAppParams symx;
 
 startCleanScreen strx;
 params:getAppParams symx;
 appCmd:(string (getAppParams symx)`inFile)," -start ",strx;
 fullCmd:"rlwrap ",qPath[],"q ",appCmd," ",qArgs[];
 sendToScreen[strx;fullCmd];
 
 }

/Utilities
removeBl: {ssr[x;" ";""]}

/Get Process Information
/Procs are of the format xxxxy, where xxxx=name of app and y=t or p
/Run with getAppParams `rxbgt

/Arg=None, Read process csv
readProcFile:{file:read0 hsym `$procFile srcDir[]}

/Arg=None, Get Table from process csv file
getProcs:{ prs:readProcFile[]; csvf: prs where not any prs like/: ("#*";""); coln: 1 + count ss[(1#csvf)0;","]; :`senv xkey update senv:`$((string session),'(string env)) from (coln#"S";enlist ",") 0: csvf }

/Arg=x = senv such as `rxbgt, Get Values from process csv file
getDefs:{[x] session:-4_string x;
 env:-4#string x;
 prs:readProcFile[];
 defs: prs where prs like "# DEFAULT*";
 d:(,)/ [{[session;env;def] a:enlist each `$"," vs removeBl raze ssr[raze ssr[ssr[def;"# DEFAULT";""];"ENV";string env];"SESSION";string session];(a 0)!a 1}[session;env;] each defs];d[`logFile]:`$(string d[`logDir]),("/",session,env,"log.txt");
 d[`fnFile]: `$(string d[`srcDir]),("/",session,"f.q");
 d[`inFile]: `$(string d[`srcDir]),("/",session,"i.q");
 :d
 }

/Arg=Sym=AppName such as `rxbgt, `commont, Get App Parameters
getAppParams:{ prs:getProcs[]; defs: getDefs[x]; thisapp:prs[x]; :$[0=sum not null thisapp;@[defs;key defs;:;`];defs]^thisapp }

getTime:{.z.Z}

msger:{[x;y]
 header:`LOGAPP;
 time:getTime[];
 user:.z.u;
 host:.z.h;
 app:x;
 pid:.z.i;
 message:$[10h~abs type y;`$y;y];
 ";" sv string each (header;time;user;host;app;pid;message)
 }

startProc:{
 params:getAppParams[x];

 /Load DB
 show msger[x;] "Loading DB ",db:string params`dbDir; 
 system "l ",db;
 
 /Set Port
 show msger[x;] "Setting Port ",port:string params`port;
 system "p ",port;

 /Load Init File
 /show msger[x;] "Loading Init ",inFile:string params`inFile;
 /system "l ",inFile;

 /Load Function File
 show msger[x;] "Loading Functions ",fnFile:string params`fnFile;
 system "l ",fnFile;

 }

args:.Q.opt .z.x;
keyargs:key args;

/If certain args are passed to the function, the following occur

if[`start in keyargs;startProc `$args[`start]0];
if[`startall in keyargs; startShellProc each exec senv from getProcs[]];
if[`exit in keyargs;exit 0];