import MultipeerConnectivity
import os

class StringReciever: NSObject, ObservableObject {
    private var serviceType:String
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    private let session: MCSession
    private let sessionChannel:FlutterMethodChannel
    private let urlToFolder:URL
    
    @Published var connectedPeer:MCPeerID?
    
    init(sessionId:String, urlToFolder:String, sessionChannel:FlutterMethodChannel) {
        self.serviceType = sessionId
        
        self.urlToFolder = URL(fileURLWithPath: urlToFolder)
        
        self.sessionChannel = sessionChannel
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .none)
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)

        super.init()

        session.delegate = self
        serviceAdvertiser.delegate = self

        serviceAdvertiser.startAdvertisingPeer()
    }

    deinit {
        serviceAdvertiser.stopAdvertisingPeer()
    }
}

extension StringReciever: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
        self.serviceAdvertiser.stopAdvertisingPeer()
    }
}


extension StringReciever: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.connectedPeer = session.connectedPeers.first
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let str = String(data: data, encoding: .utf8) {
            DispatchQueue.main.async {
                        self.sessionChannel.invokeMethod("dataRecieved", arguments: str)
                    }
            } else {
                print("error recieving data")
            }
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("started to recieve file")
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        //File downloaded by Session at localURL so must be moved to desired URL
        print("file fully recieved")
        do{
            
            let defaultDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let defaultFileUrl = defaultDir.appendingPathComponent(resourceName)
            let appDirFile = urlToFolder.appendingPathComponent(resourceName)
            
            //For the moment having rights isues while trying to copy the file to the user's desired location. Therefore copying the file to the default App Directory
            
            
            /*if appDirFile.startAccessingSecurityScopedResource(){
                try FileManager.default.copyItem(atPath: localURL!.path, toPath: defaultFileUrl.path)
                try FileManager.default.copyItem(atPath: localURL!.path, toPath: appDirFile.path)
                appDirFile.stopAccessingSecurityScopedResource()
            }
            else{*/
                //try FileManager.default.copyItem(atPath: localURL!.path, toPath: defaultFileUrl.path)
                try FileManager.default.copyItem(atPath: localURL!.path, toPath: appDirFile.path)
            //}
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    
    }
    
}
