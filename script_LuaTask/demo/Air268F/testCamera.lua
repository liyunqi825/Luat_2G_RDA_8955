--- 模块功能：camera功能测试.
-- @author openLuat
-- @module fs.testFs
-- @license MIT
-- @copyright openLuat
-- @release 2018.03.27

module(...,package.seeall)

require"pm"
require"scanCode"
require"utils"
require"audio"

local WIDTH,HEIGHT = disp.getlcdinfo()
local DEFAULT_WIDTH,DEFAULT_HEIGHT = 240,320

local opened

-- 打开摄像头（此接口默认打开扫码功能，后续再完善）
-- @bool scanCode，true表示打开扫码功能，false或者nil表示不打开扫码功能
local function open(scanCode)
    --打开摄像头
    if not opened then
        --disp.cameraopen(1,scanCode and 1 or 0)
        disp.cameraopen(1,1)
        opened = true
    end
end

-- 扫码结果回调函数
-- @bool result，true或者false，true表示扫码成功，false表示超时失败
-- @string[opt=nil] codeType，result为true时，表示扫码类型；result为false时，为nil；支持如下几种：
--               R-Code、CODE-128、EAN-8、UPC-E、ISBN-10、UPC-A、EAN-13、ISBN-13、I2/5、CODE-39、PDF417
-- @string[opt=nil] codeStr，result为true时，表示扫码结果的字符串；result为false时，为nil
local function scanCodeCb(result,codeType,codeStr)
    --关闭摄像头预览
    disp.camerapreviewclose()
    --允许系统休眠
    pm.sleep("testScanCode")
    --500毫秒后处理扫描结果
    sys.timerStart(function()
        --如果有LCD，显示扫描结果
        if WIDHT~=0 and HEIGHT~=0 then 
            disp.clear()
            if result then
                disp.puttext(common.utf8ToGb2312("扫描成功"),0,5)
                disp.puttext(common.utf8ToGb2312("类型：")..codeType,0,35)
                --log.info("scanCodeCb",codeStr:toHex())
                disp.puttext(common.utf8ToGb2312("结果：")..codeStr,0,65)                
            else
                disp.puttext(common.utf8ToGb2312("扫描失败"),0,5)                
            end
            disp.update()
            
            sys.timerStart(windows.returnIdle,5000)
        end
        
        --TTS播报扫描结果
        if result then
            audio.play(0,"TTS","扫描成功")
        else
            audio.play(0,"TTS","扫描失败")
        end
    end,500)    
    
end

--扫码
function scan()
    --唤醒系统
    pm.wake("testScanCode")
    --设置扫码回调函数，默认10秒超时
    scanCode.request(scanCodeCb)
    --打开摄像头
    open(true)
    --打开摄像头预览
    --如果有LCD，使用LCD的宽和高
    --如果无LCD，宽度设置为240像素，高度设置为320像素，240*320是Air268F支持的最大像素
    disp.camerapreview(0,0,0,0,WIDHT or DEFAULT_WIDTH,HEIGHT or DEFAULT_HEIGHT)
end

-- 拍照
function takePhoto()
    --唤醒系统
    pm.wake("testTakePhoto")
    --打开摄像头
    open(false)
    --打开摄像头预览
    --如果有LCD，使用LCD的宽和高
    --如果无LCD，宽度设置为240像素，高度设置为320像素，240*320是Air268F支持的最大像素
    disp.camerapreview(0,0,0,0,WIDHT or DEFAULT_WIDTH,HEIGHT or DEFAULT_HEIGHT)
    --设置照片的宽和高像素并且开始拍照
    --此处设置的宽和高和预览时的保持一致
    disp.cameracapture(WIDHT or DEFAULT_WIDTH,HEIGHT or DEFAULT_HEIGHT)
    --设置照片保存路径
    disp.camerasavephoto("/testCamera.jpg")
    log.info("testCamera.takePhoto fileSize",io.fileSize("/testCamera.jpg"))
    --关闭摄像头预览
    disp.camerapreviewclose()
    --允许系统休眠
    pm.sleep("testTakePhoto")
    
    --显示拍照图片    
    if WIDHT~=0 and HEIGHT~=0 then
        disp.clear()
        --目前的lod软件，直接显示拍照图片会重启，后续再修改此问题
        --disp.putimage("/testCamera.jpg",0,0)
        disp.puttext(common.utf8ToGb2312("照片尺寸: "..io.fileSize("/testCamera.jpg")),0,5)
        disp.update()
    end
    
    
    --5秒后自动返回提示界面
    sys.timerStart(windows.returnIdle,5000)
end
