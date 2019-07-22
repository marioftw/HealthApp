import UIKit
import AVFoundation
import RealmSwift
//import SCLAlertView

class QRAnalyzerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet var videoPreview: UIView!
    var patientUID = ""
    let realm = try? Realm()
    var doctor: Doctor!
    
    enum error: Error {
        case noCameraAvailable
        case videoInputInitFail
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try scanQRCode()
        } catch {
            /*let appearance = SCLAlertView.SCLAppearance( showCloseButton: false )
             let alert = SCLAlertView(appearance: appearance)
             alert.addButton("OK", action: {})
             alert.showError("Error", subTitle: NSLocalizedString("QRAnalyzer.error", comment: ""))*/
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count > 0 {
            let machineReadeableCode = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            if machineReadeableCode.type == AVMetadataObject.ObjectType.qr {
                patientUID = machineReadeableCode.stringValue!
                DatabaseService.shared.patientsRef.child(patientUID).observeSingleEvent(of: .value) {
                    (snapshot) in
                    if let patientDict = snapshot.value as? Dictionary<String, AnyObject> {
                        if let _ = patientDict["profile"] as? Dictionary<String, AnyObject> {
                            DispatchQueue.main.async {
                                DatabaseService.shared.addPatient(doctorUID: self.doctor.uid, patientUID: self.patientUID)
                                NotificationCenter.default.post(name: NSNotification.Name("UpdatePatientsTable"), object: nil)
                                self.dismiss(animated: true)
                            }
                        }
                        
                    } // Cannot create patient dict
                } // Patient doesn't exists
                
            } // Unable to create the reading object
        }
    }
    
    func scanQRCode() throws {
        let avCaptureSession =  AVCaptureSession()
        guard let avCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("No camera available")
            throw error.noCameraAvailable
        }
        
        guard let avCaptureInput = try? AVCaptureDeviceInput(device: avCaptureDevice) else {
            print("Failed to  init camera")
            throw error.videoInputInitFail
        }
        
        let avCaptureMetadataOutput = AVCaptureMetadataOutput()
        avCaptureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        avCaptureSession.addInput(avCaptureInput)
        avCaptureSession.addOutput(avCaptureMetadataOutput)
        
        avCaptureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        let avCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: avCaptureSession)
        avCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        avCaptureVideoPreviewLayer.frame = videoPreview.bounds
        self.videoPreview.layer.addSublayer(avCaptureVideoPreviewLayer)
        avCaptureSession.startRunning()
    }
}
