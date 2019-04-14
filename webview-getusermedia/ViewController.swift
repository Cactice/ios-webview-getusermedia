import UIKit
import AVFoundation
import Photos
import WebKit
import MobileCoreServices


class ViewController: UIViewController,  WKUIDelegate, WKScriptMessageHandler, AVCaptureFileOutputRecordingDelegate{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == "callbackHandler") {
            print("JavaScript is sending a message \(message.body)")
        }
    }
    

    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("Video save done. Stream start.")
        
        let file = FileManager.default
        
        sendToWebView(webView,param: outputFileURL.absoluteString)
//        self.createUploader().upload(data: try! NSData(contentsOf: outputFileURL as URL) as Data, uploadPreset: "diaqduck", params: params as? CLDUploadRequestParams, progress:{ progress in
//        }) { (response, error) in
//            // Handle response
//            print(error)
//            self.streamCounter+=1
//            print("stream:")
//            print(self.streamCounter)
//            try! file.removeItem(at:outputFileURL)
//
//        }
    }
    
    
    
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var webviewView: UIView!
    
    
    // デバイスからの入力と出力を管理するオブジェクトの作成
    var captureSession = AVCaptureSession()
    // カメラデバイスそのものを管理するオブジェクトの作成
    // メインカメラの管理オブジェクトの作成
    var mainCamera: AVCaptureDevice?
    // インカメの管理オブジェクトの作成
    var innerCamera: AVCaptureDevice?
    // 現在使用しているカメラデバイスの管理オブジェクトの作成
    var currentDevice: AVCaptureDevice?
    // キャプチャーの出力データを受け付けるオブジェクト
    // プレビュー表示用のレイヤ
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    var filePath : String?
    var timer: Timer?
    let fileOutput = AVCaptureMovieFileOutput()
    var streamCounter = 0
    var saveCounter = 0
    var webView: WKWebView!
    
    override func loadView() {
        super.loadView()
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: webviewView.frame, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    

    override func viewDidLoad() {
        
        let webviewConfig: WKWebViewConfiguration = WKWebViewConfiguration()
        let userController: WKUserContentController = WKUserContentController()
        userController.add(self, name: "callbackHandler")
        webviewConfig.userContentController = userController
        
        super.viewDidLoad()
        
        let path: String = Bundle.main.path(forResource: "index", ofType: "html")!
        
        let myURL =  URL(fileURLWithPath: path, isDirectory: false)
        let myRequest = URLRequest(url: myURL)
        webView.load(myRequest)
        
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        captureSession.startRunning()
        self.timer = Timer.scheduledTimer(timeInterval: 3.0,
                                          target: self,
                                          selector: #selector(ViewController.Interval),
                                          userInfo: nil,
                                          repeats: true)
    }
    
    @objc func Interval(){
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let cachesDirectory = paths[0] as String
        
        self.saveCounter += 1
        filePath = "\(cachesDirectory)/temp\(saveCounter).mp4"
        let fileURL = NSURL(fileURLWithPath: filePath!)
        self.fileOutput.startRecording(to: fileURL as URL, recordingDelegate: self as AVCaptureFileOutputRecordingDelegate)
        print("cut")
        print(self.saveCounter)
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

extension ViewController{
    func sendToWebView(_ webView: WKWebView, param: String) {
        // Javascript側で実行する関数
        let execJsFunc: String = "test(\"\(param)\");"
        DispatchQueue.main.async{
            webView.evaluateJavaScript(execJsFunc, completionHandler: { (object, error) -> Void in
                
        })
        }
    }
}
//MARK: カメラ設定メソッド
extension ViewController{
    
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.medium
    }
    // カメラの画質の設定
    func setupWebview() {
        captureSession.sessionPreset = AVCaptureSession.Preset.medium
    }
    
    // デバイスの設定
    func setupDevice() {
        // カメラデバイスのプロパティ設定
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        // プロパティの条件を満たしたカメラデバイスの取得
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                mainCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                innerCamera = device
            }
        }
        // 起動時のカメラを設定
        currentDevice = mainCamera
    }
    
    // 入出力データの設定
    func setupInputOutput() {
        do {
            // 指定したデバイスを使用するために入力を初期化
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            // 指定した入力をセッションに追加
            captureSession.addInput(captureDeviceInput)
            // 出力データを受け取るオブジェクトの作成
            // 出力ファイルのフォーマットを指定
            
            captureSession.addOutput(fileOutput)
        } catch {
            print(error)
        }
    }
    
    // カメラのプレビューを表示するレイヤの設定
    func setupPreviewLayer() {
        // 指定したAVCaptureSessionでプレビューレイヤを初期化
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        // プレビューレイヤが、カメラのキャプチャーを縦横比を維持した状態で、表示するように設定
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        // プレビューレイヤの表示の向きを設定
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        self.cameraPreviewLayer?.frame = cameraView.frame
    cameraView.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
    }
}
