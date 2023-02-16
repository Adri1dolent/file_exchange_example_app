import MultipeerConnectivity
import os

class StringSender: NSObject, ObservableObject {
    private var serviceType:String
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    private let session: MCSession
    private let sessionChannel:FlutterMethodChannel
    
    @Published var connectedPeer:MCPeerID?
    
    init(sessionId:String, sessionChannel:FlutterMethodChannel) {
        self.serviceType = sessionId
        self.sessionChannel = sessionChannel
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .none)
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        
        super.init()
        
        session.delegate = self
        serviceBrowser.delegate = self
        
        serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        serviceBrowser.stopBrowsingForPeers()
    }
    
    func send(str: String) {
        if !session.connectedPeers.isEmpty {
            do {
                try session.send(str.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                print("error sending string")
            }
        }
    }
    
    func sendFile(url: String){
        
        let urlObj = URL(fileURLWithPath: url)
        let fname = urlObj.lastPathComponent
        let appDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let appDirFile = appDir.appendingPathComponent(fname)
        if FileManager.default.fileExists(atPath: appDirFile.path){
            print("File alredy copied in app dir")
        }
        else{
            do{
                print("file path :::: ", urlObj)
                print("folder path ::::", appDir)
                try FileManager.default.copyItem(at: urlObj, to: appDirFile)
            } catch {
                print("erreur :::: ",error.localizedDescription)
                return
            }
        }
        
        print("just omg")
        if !session.connectedPeers.isEmpty {
            session.sendResource(at: appDirFile, withName: fname, toPeer: connectedPeer!)
        }
    }
}
    

extension StringSender: MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        if(self.connectedPeer == nil ){
            browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
    }

}

extension StringSender: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
            DispatchQueue.main.async {
                self.connectedPeer = session.connectedPeers.first
                if(state == MCSessionState.connected){
                    print("wtfffff")
                    self.sessionChannel.invokeMethod("onPeerConnected", arguments: peerID.displayName)
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
    }

    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }

    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }

    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
}
