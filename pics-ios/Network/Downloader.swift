//
//  Downloader.swift
//  pics-ios
//
//  Created by Michael Skogberg on 26/11/2017.
//  Copyright © 2017 Michael Skogberg. All rights reserved.
//

import Foundation

class Downloader {
    static let shared = Downloader()
    private let log = LoggerFactory.shared.network(Downloader.self)
    fileprivate var tasks = [URLSessionTask]()
    private let queue = DispatchQueue(label: "DownloaderTaskQueue")
    
    // https://andreygordeev.com/2017/02/20/uitableview-prefetching/
    func download(url: URL, onData: @escaping (Data) -> Void) {
//        log.info("Submitting download of \(url)")
        self.queue.sync {
            guard tasks.index(where: { $0.originalRequest?.url == url }) == nil else {
                // We're already downloading the URL
                log.warn("Already downloading \(url.absoluteString), aborting")
                return
            }
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            self.queue.sync {
                if let idx = self.tasks.index(where: { $0.originalRequest?.url == url }) {
                    self.tasks.remove(at: idx)
                }
            }
            let log = self.log
            if let error = error {
                if error.localizedDescription == "cancelled" {
                    log.info("Cancelled \(url)")
                } else {
                    log.error("Download failed with error \(error)")
                }
            } else {
                if let data = data {
                    onData(data)
                } else {
                    log.warn("No data returned in download of \(url.absoluteString), but also no error reported")
                }
            }
        }
        task.resume()
        self.queue.sync {
            tasks.append(task)
        }
    }
    
    func cancelDownload(forUrl url: URL) {
        queue.sync {
            guard let taskIndex = tasks.index(where: { $0.originalRequest?.url == url }) else {
                return
            }
            let task = tasks[taskIndex]
            task.cancel()
            tasks.remove(at: taskIndex)
        }
    }
}
