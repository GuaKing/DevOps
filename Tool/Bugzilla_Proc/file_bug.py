import sys
import mechanicalsoup
from http import cookiejar
import Bugzilla_Pak

stream = sys.argv[1]
RL_VERSION = sys.argv[2]
Product = 'Xxxxxxxxxxxxxxxxxxx'
Component = 'Xxxxxxxxxxxxxxxxxxx'
version = 'R{}'.format(RL_VERSION.split('-')[0])
Summary = '[LTE Build]: Release for {}'.format(RL_VERSION)
Target_stream = "Feature Stream"
url='xxxxxxxx'
bz_User = 'Xxxxxxxxxxxxxxxxxxx'
bz_Passwd = 'xxxxxxxxxxxxxxxxxx'
Br = mechanicalsoup.StatefulBrowser(
    soup_config={'features': 'lxml'},  # Use the lxml HTML parser
    raise_on_404=True,
    user_agent='Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:67.0) Gecko/20100101 Firefox/67.0',
)
Cj = cookiejar.LWPCookieJar()

def checkStream(stream):
    global Target_stream
    if "_INT" in stream:
        Target_stream = stream
        print("in check:",Target_stream)

def processUrl(url,Product):
    newUrl = '{}/enter_bug.cgi?product={}'.format(url,Product.replace(' ','%20'))
    return newUrl

def showInfo(V,T):
    width = 100
    value_width = 60
    title_width = width - value_width
    header_fmt = '{{:{}}}{{:>{}}}'.format(title_width, value_width)
    fmt = '{{:{}}}{{:>{}}}'.format(title_width, value_width)
    print('=' * width)
    print(header_fmt.format('Item', 'Value'))
    print('-' * width)
    for t, v in zip(T,V): print(fmt.format(t, v))
    print('=' * width)

listV = [Component, version, Target_stream, Summary]
listT = ['component', 'version', 'cf_target_stream', 'short_desc']
showInfo(listV,listT)

Bugzilla_Pak.loginBz(url,Br,Cj,bz_User,bz_Passwd)
Product_url=processUrl(url,Product)
Values={}
##Values={r'component':Component,r'version':version,r'cf_target_stream':Target_stream,r'short_desc':Summary}

for i in range(len(listT)):Values[r'{}'.format(listT[i])]=listV[i]
Bugzilla_Pak.setValue(Br,Product_url,Values)

print(Br.get_current_page().title.text)

ISSUE_ID=Br.get_current_page().title.text.split()[1]
print('Bug:{}'.format(ISSUE_ID))
f = open('ISSUE_ID.txt', 'w', newline='\n')
f.write(r'ISSUE_ID'+'={}\n'.format(ISSUE_ID))
f.close()

Br.close()
