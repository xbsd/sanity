
/ Common Settings: Logging, Init Functions, Others

\d .app

/ Set Env. Vars
srcDir:   {"/app/db/src"};
procFile: {raze x,"/t/common/proctable.csv"};

/Screen Process Utilities

createScreen:   {system "screen -dm ",x} /Accepts String ("rxbgt")
getScreenCount: {system ("screen -ls | grep "),x," | wc -l"}
sendToScreen:   {system "screen -S ",x," -p 0 -X stuff ",y,"$(printf \\\\r); true"} /Send to screen x the command y (strings)
killScreen:     {system "screen -ls | grep ",x," | cut -f1 -d'.' | sed 's/\\W//g' | xargs kill -9; screen -wipe;true"}
startCleanScreen: { killScreen x; createScreen x }


/Utilities
removeBl: {ssr[x;" ";""]}

/Get Process Information
/Procs are of the format xxxxy, where xxxx=name of app and y=t or p
/Run with getAppParams `rxbgt

/Arg=None, Read process csv
readProcFile:{file:read0 hsym `$procFile srcDir[]}

/Arg=None, Get Table from process csv file
getProcs:{ prs:readProcFile[]; csvf: prs where not prs like "#*"; coln: 1 + count ss[(1#csvf)0;","]; :`senv xkey update senv:`$((string session),'(string env)) from (coln#"S";enlist ",") 0: csvf }

/Arg=x = senv such as `rxbgt, Get Values from process csv file
getDefs:{[x] session:-1_string x; env:-1#string x; prs:readProcFile[]; defs: prs where prs like "# DEFAULT*"; d:(,)/ [{[session;env;def] a:enlist each `$"," vs removeBl raze ssr[raze ssr[ssr[def;"# DEFAULT";""];"ENV";string env];"SESSION";string session];(a 0)!a 1}[session;env;] each defs];d[`logFile]:`$(string d[`logDir]),("/",session,env,"log.txt"); d[`fnFile]: `$(string d[`srcDir]),("/",session,env,"f.q");:d}

/Arg=Sym=AppName such as `rxbgt, `commont, Get App Parameters
getAppParams:{ prs:getProcs[]; defs: getDefs[x]; thisapp:prs[x]; :$[0=sum not null thisapp;@[defs;key defs;:;`];defs]^thisapp }







