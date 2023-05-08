curl -Lsko "%temp%\python-3.10-x64.exe" https://downloads.sourceforge.net/project/portable-python/Portable%20Python%203.10/Portable%20Python-3.10.5%20x64.exe
"%temp%\python-3.10-x64.exe"

echo Add the below to your profile if not already there.
echo .
echo alias pip=python -m pip $*
echo set Path=C:\Users\vagrant\cmderdev\bin\python-3.10.5-x64\App\Python;C:\Users\vagrant\cmderdev\bin\python-3.10.5-x64;\%path\%
echo set PYTHONHOME=C:\Users\vagrant\cmderdev\bin\python-3.10.5-x64\App\Python
echo set PYTHONPATH=C:\Users\vagrant\cmderdev\bin\python-3.10.5-x64\App\Python
echo set PYTHONSTARTUP=C:\Users\vagrant\cmderdev\bin\python-3.10.5-x64\App\Python\Lib\ppp.py

