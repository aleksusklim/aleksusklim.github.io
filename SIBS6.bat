@echo off
setlocal disabledelayedexpansion enableextensions

rem . SIBS (Site Index Batch Script) v1.6, Kly_Men_COmpany!
rem . Run it to create an index page here and in almost every subfolder.
rem . Custom settings are below:

set root=
set index=index.html
set ignore=.tmp
set include=include
set noindex=noindex
set copyto=

rem . root - name of the current folder relative to site's root
rem . index - name of target index file
rem . ignore - extension to skip (also all hidden files)
rem . include - must be present in each processed directory
rem . noindex - if present then a folder will be included but not processed
rem . copyto - folder to store index structure

title %~nx0
set tmpr=%~s0.tmp
if "%1" == "" (
set name=%root%
set way=%~dp0%copyto%
set bat=%0
set sibs=%~n0
set root="1"
set "glist=%~dp0%~n0.txt"
cd.>"%~dp0%~n0.txt"
call :js
) else (
setlocal
set root=":"
set name=%1
set way=%~2
set sibs=../%sibs%
)
if not exist "%include%" goto :eof
if exist "%noindex%" goto :eof
echo %name%
echo "@%doc%Index of %name%/%css%<script>var p=(document.location.pathname+'/').replace(/\/+/g,'/').replace(/\/[^\/]*\.html?\/$/ig,'/');if(''+document.location.pathname!=p)document.location.pathname=p;</script><h1>Index of</h1><h2>%name%/</h2><table>@">%tmpr%
(
if %root%==":" echo "@<tr><td><a href='../'>../ &lpar;parent&rpar;</a></td><td></td><td></td></tr><tr><td></td><td></td><td></td></tr>@"
for /d %%i in (*) do call :dirs "%%~i" "%%~ti"
echo "@<tr><td></td><td></td><td></td></tr>@"
for %%i in (*) do call :loop "%%~i" "%%~zi" "%%~ti" "%%~si" %tmpr%
)>>%tmpr%
echo "@</table><h6>Created with <a href='%sibs%.bat'> %~n0 </a> | <a href='%sibs%.htm'><i>Search files!</i></a></h6>%end%@">>%tmpr%
(
for /f "tokens=2 delims=@" %%i in (%tmpr%) do echo %%i
)>%index%
if defined copyto if not exist "%way%" mkdir "%way%"
if defined copyto copy /y %index% "%way%" >nul
del /q /f %tmpr%
for /d %%i in (*) do call :tree "%%~i"
if defined copyto if "%~1" == "" copy /y %sibs%.txt "%copyto%%sibs%.txt"
goto :eof
:dirs
if exist "%~1\%include%" goto :donext
if exist "%~1\%noindex%" goto :donext
goto :eof
:donext
echo "@<tr><td><a href='%~1/'>%~1/</a></td><td><i>%~2</i></td><td></td></tr>@"
goto :eof
:loop
if "%~x1"=="%ignore%" goto :eof
if "%~1"=="%include%" goto :eof
if "%~1"=="%index%" goto :eof
if %~s4==%~s5 goto :eof
call :sizer %~2
echo "@<tr><td><a href='%~1'>%~1</a></td><td title=%~2>%size%</td><td><i>%~3</i></td></tr>@"
echo %~1	%~2	%~3	%name%/>>%glist%
goto :eof
:tree
pushd %1
call %bat% %name%/%~1 %way%/%~1 
popd
goto :eof
:sizer
set /a s=%1
if "%s%"=="0" (
set size=^<u^>N/a^</u^>
goto :eof
)
if /i %s% lss 1024 (
set size=%s% b
goto :eof
)
if /i %s% lss 1000000 (
set /a s=%s%*1000/1024
) else (
set /a s=%s%/1024*1000
)
if /i %s% lss 10000 (
set size=%s:~0,1%.%s:~1,2% Kb
goto :eof
)
if /i %s% lss 100000 (
set size=%s:~0,2%.%s:~2,1% Kb
goto :eof
)
if /i %s% lss 1000000 (
set size=%s:~0,3% Kb
goto :eof
)
set /a s=%s%/1024
if /i %s% lss 10000 (
set size=^<b^>%s:~0,1%.%s:~1,2% MB^</b^>
goto :eof
)
if /i %s% lss 100000 (
set size=^<b^>%s:~0,2%.%s:~2,1%^ Mb^</b^>
goto :eof
)
goto :eof
:js
set "doc=<!doctype html><html><head><meta charset=utf-8><title>"
set "css=</title><style id=mystyle>th{text-align:left;}table th>a{color:gray;text-decoration:underline;font-weight:normal;font-size:80%%;}table,tr,td,th,h1,h2,h6,body,input{border:0;padding:2px 6px;margin:2px 6px;font-family:Courier New,Courier,monospace;}input[type='text']{border:1px dashed gray;width:60%%;font:normal 16pt Courier New,Courier,monospace;}a{padding:0;margin:0;text-decoration:none;border-bottom:0;font-weight:bold;}a:hover{border-bottom-width:1px;border-bottom-style:solid;}</style></head><body><div id=myform>"
set "end=</div><script>setTimeout(function(h){h='<!doctype html><html><head><meta charset=utf-8><title>'+document.title+'</title><style id=mystyle>'+document.getElementById('mystyle').innerHTML+'</style></head><body><div id=myform>'+document.getElementById('myform').innerHTML+'</div></'+'body></'+'html>';document.open();document.write(h);document.close();if(window.stop)window.stop();if(document.execCommand)document.execCommand('Stop');});</script><xmp style='display:none;'></body></html>"
set "js=<h1>Search files:</h1><h2><form onsubmit='Proc(1);event.preventDefault();return false;'><input type='text' onkeydown='Proc()' onkeyup='Proc()' onchange='Proc();' id='myrequest'><label><input type='checkbox' onchange='Proc(1);' id='mybig'> by size</label></form></h2><br /><hr /><div id='mytarget'></div><script>window.Proc=function(f,z){if(!Proc.Done)Proc.Done=function(){document.getElementById('mytarget').innerHTML=Proc.Exec(Proc.Find,Proc.Data,document.getElementById('mybig').checked);};if(!Proc.Data)return;if(!Proc.Size)Proc.Size=function(s){var r='';if(s>0){if(s<1024)return s+' b';if(s<1000000)s=s*1000/1024;else s=s/1024*1000;s=Math.floor(s);r=''+s;if(s<10000)return r.substr(0,1)+'.'+r.substr(1)+' Kb';if(s<100000)return r.substr(0,2)+'.'+r.substr(2,1)+' Kb';if(s<1000000)return r.substr(0,3)+' Kb';s=Math.floor(s/1024);r=''+s;if(s<10000)return '<b>'+r.substr(0,1)+'.'+r.substr(1,2)+' Mb</b>';if(s<100000)return '<b>'+r.substr(0,2)+'.'+r.substr(2,1)+' Mb</b>';};return '<u>N/a</u>';};if(!Proc.Exec)Proc.Exec=function(s,t,q){s.replace(/[^0-9a-zA-Z_+., -]/g,'').replace(/\s+/g,' ').trim().split(' ').map(function(s){if(s&&t){t=t.match(new RegExp('^.*?(?:'+s.replace(/(.)/g,'[$1]')+').*?(?:\t[^\t]+){3}$','igm'));if(t)t=t.join('\n');}});var r='<table>';if(t){t=t.trim().split('\n').map(function(s){return s.split('\t')});t=t.sort(q?function(a,b){return b[1]-a[1];}:function(a,b){a=a[0].toLowerCase();b=b[0].toLowerCase();return a>b?1:(a<b?-1:0);});t.map(function(s){r+='<tr><th><a href='+s[3]+'>'+s[3]+'</a></th><td><a href='+s[3]+s[0]+'>'+s[0]+'</a></td><td>'+Proc.Size(s[1])+'</td><td><i>'+s[2]+'</i></td></tr>';});}r+='</table>';return r;};var d=document.getElementById('myrequest').value;if(f||Proc.Find!==d){Proc.Find=d;clearTimeout(Proc.Time);Proc.Time=setTimeout(Proc.Done,f?1:2000);};};setTimeout(function(){document.getElementById('myframe').src='SIBS6.txt';document.getElementById('myrequest').focus();},100);</script><iframe onload='window.Proc.Data=this.contentDocument.body.textContent;window.Proc(1);' style='position:absolute;left:-9999px;height:10px;' id='myframe'></iframe><hr /><h6>Created with <a href='SIBS6.bat'> SIBS6 </a></h6>"
setlocal enabledelayedexpansion
echo !doc!Search files!css!!js!!end!>!sibs!.htm
endlocal
goto :eof