// The MIT License (MIT)
//
// Copyright (c) 2017 Ruike Gong
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


import Alamofire

open class RKRequestQueue: RKRequestQueueType {
    //
    open let sessionManager: SessionManager
    //
    open let configuration: RKConfiguration
    //
    open var activeRequestCount: Int = 0
    //
    open var delegate: RKRequestQueueDelegate?
    //
    private var lock: NSLock = NSLock()
    //
    open var queuedRequests: [RKRequestable] = []
    //
    let synchronizationQueue: DispatchQueue = {
        let name = String(format: "cn.rk.request.synchronization.queue-%08%08", arc4random(), arc4random())
        return DispatchQueue(label: name)
    }()
    
    public init(configuration: RKConfiguration) {
        
        self.configuration = configuration
        
        self.sessionManager = SessionManager(configuration: configuration.configuration,
                                             delegate: SessionDelegate(),
                                             serverTrustPolicyManager: configuration.trustPolicyManager)
        // Important
        self.sessionManager.startRequestsImmediately = false
    }
    
    open func addRequest(_ request: RKRequestable) {
        //
        synchronizationQueue.async {
            //
            if self.isActiveRequestCountBelowMaximumLimit() {
                //
                self.startRequest(request)
            } else {
                //
                self.enqueueRequest(request)
            }
        }
    }

    private func startRequest(_ request: RKRequestable) {
        //
        request.serializeRequest(in: self)
        //
        request.start()
    }
    
    private func startNextRequest() {
        //
        guard isActiveRequestCountBelowMaximumLimit() else { return }
        //
        guard let request = dequeueRequest() else { return }
        //
        startRequest(request)
    }
    
    private func enqueueRequest(_ request: RKRequestable) {
        //
        switch configuration.prioritization {
        case .fifo:
            queuedRequests.append(request)
        case .lifo:
            queuedRequests.insert(request, at: 0)
        }
    }
    
    private func dequeueRequest() -> RKRequestable? {
        //
        var request: RKRequestable?
        //
        if !queuedRequests.isEmpty {
            request = queuedRequests.removeFirst()
        }
        //
        return request
    }
    
    private func isActiveRequestCountBelowMaximumLimit() -> Bool {
        //
        return activeRequestCount < configuration.maximumActiveRequestCount
    }
    
    open func onSendRequest(_ request: RKRequestable) {
        //
//        synchronizationQueue.async { [weak self]
//            //
//            self?.lock.lock()
//            self?.activeRequestCount += 1
//            self?.lock.unlock()
//        }
        lock.lock()
        activeRequestCount += 1
        lock.unlock()
    }
    
    open func onFinishRequest(_ request: RKRequestable) {
        //
//        synchronizationQueue.async { [weak self]
//            //
//            self?.lock.lock()
//            self?.activeRequestCount += 1
//            self?.lock.unlock()
//        }
        //
        lock.lock()
        //
        activeRequestCount -= 1
        startNextRequest()
        //
        lock.unlock()
    }
    
}
