def loginBz(url,br,cj,user,passwd):
    br.set_cookiejar(cj)
    br.open(url)
    formLogin = br.select_form(nr=1)
    formLogin.set("Bugzilla_login", user)
    formLogin.set("Bugzilla_password", passwd)
    br.submit_selected()

def setValue(br,url,di):
    ##di is a directory which include{item:value}
    br.open(url)
    formLogin = br.select_form(nr=1)
    for d in di:
        formLogin.set(d, di[d])
    #br.submit_selected()
    #br.launch_browser()
