import Foundation
import Files
import TractorEntity

enum OutputFileParserError: Error {
    case outputFolderNotFound
    case cannotGenerateReportWrapper
}

struct ReportWrapper {
    let numberOfSuccess: Int
    // TODO: Include the number of failures by each test
    let failureTests: [FailureTest]
    
    var numberOfFailures: Int {
        return failureTests.count
    }
    
    var numberOfTests: Int {
        return numberOfSuccess + numberOfFailures
    }
}

final class OutputFileParser {
    
    func getReportWrapper() throws -> ReportWrapper {
        
        do {
            let folder = try getOutputFolder()
            let content = getRawContent(for: folder)
            let outputs = getTractorOutput(with: content)
            
            let success = outputs.map { $0.testMetrics }.reduce(0, { count, testMetrics in
                count + testMetrics.count
            })
            
            let failureTests = outputs.map { $0.failures }.flatMap { $0 }
            
            return ReportWrapper(
                numberOfSuccess: success,
                failureTests: failureTests
            )
        } catch {
            throw OutputFileParserError.cannotGenerateReportWrapper
        }
        
    }
    
    private func getOutputFolder() throws -> Folder {
        do {
            let folder = try Folder.current.subfolder(named: "tractor-output")
            return folder
        } catch {
            throw OutputFileParserError.outputFolderNotFound
        }
    }
    
    private func getRawContent(for folder: Folder) -> [String] {
        let files = folder.files
        // maybe throw if file is empty
        let fileNamePrefix = "to-"
        
        var rawContent: [String] = []
        for file in files where file.name.contains(fileNamePrefix) {
            if let stringContent = try? file.readAsString() {
                rawContent.append(stringContent)
            }
        }
        
        // maybe throw if array is empty
        return rawContent
    }
    
    private func getTractorOutput(with rawContent: [String]) -> [TractorOutput] {
        var output: [TractorOutput] = []
        
        for raw in rawContent {
            guard let data = raw.data(using: .utf8) else { break }
            
            if let tractorOutput = try? TractorOutput.decoder.decode(TractorOutput.self, from: data) {
                output.append(tractorOutput)
            }
        }
        
        return output
    }
    
}
