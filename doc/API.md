# APIs
## http
### > jmu.edu.cn
#### >> oa99
`/v2/passport/api/user/login1 (application/json)` 登录
```JSON
{
    "appid":"273",
    "blowfish":"UUID.randomUUID()",
    "account":"20152103xxxx",
    "password":"sha1(password)",
    "encrypt":1,
    "flag":1,
    "unitid":55,
    "imgcode":"",
    "clientinfo": {
        "appid":"273",
        "platform":30,
        "platformver":"2.3.1",  // Any version can be.
        "deviceid":"IMEI",
        "devicetype":"OPPO R11",
        "systype":"android",
        "sysver":"2.1"  // Any version can be.
    }  // clientinfo must be stringify.
}
```
`/v2/api/class/studentinfo?uid=136172` 个人资料

#### >> oa99p
`face?uid=${uid}&size=f152` 头像

#### >> wb
`/topic_api/galances`查看时触发，增加阅读次数

#### >> album
`/photo?uid=${uid}&app=jmu&apitype=u&unitid=55&sid=${sid}` 获取用户相册