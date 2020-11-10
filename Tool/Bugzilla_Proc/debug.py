import sys
import mechanicalsoup
from http import cookiejar
import Bugzilla_Pak
import importlib
importlib.reload(sys)
bz_User = sys.argv[1]
bz_Passwd = sys.argv[2]

url = 'xxxxxxxxxxxxxxxxx'
Br = mechanicalsoup.StatefulBrowser(
    soup_config={'features': 'lxml'},  # Use the lxml HTML parser
    raise_on_404=True,
    user_agent='Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:67.0) Gecko/20100101 Firefox/67.0',
)
Cj = cookiejar.LWPCookieJar()
Bugzilla_Pak.loginBz(url,Br,Cj,bz_User,bz_Passwd)

url_new ='xxxxxxxxxxxxxxxxx'
Bugzilla_Pak.setValue(Br, url_1,{"value":version})

keyL = ["bug_status", "cf_major_version"]
lvalue = getOptionValue(Br, url_show_bug, keyL)

status = lvalue["bug_status"]
version = ltevalue["cf_major_version"]
