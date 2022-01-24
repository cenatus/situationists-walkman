/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Parser to import ARGeoAnchors from GPX files.
*/

import ARKit

protocol GPXParserDelegate: AnyObject {
    func parser(_ parser: GPXParser, didFinishParsingFileWithAnchors speakers: [Speaker])
}

class GPXParser: NSObject, XMLParserDelegate {
    
    weak var delegate: GPXParserDelegate?
    
    // The XML parser used to parse the GPX file.
    private var parser: XMLParser?
    
    // The data of the currently parsed geo anchor.
    private var parsedSpeakerData = [String: String]()
    
    // The textual content of the currently parsed element.
    private var currentElementText = ""
    
    private var speakersFoundInFile: [Speaker] = []
    
    init?(contentsOf url: URL) {
        guard let parser = XMLParser(contentsOf: url) else {
            return nil
        }
        super.init()
        parser.delegate = self
        self.parser = parser
    }
    
    func parse() {
        parser?.parse()
    }
    
    // MARK: - XMLParserDelegate
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        // Each waypoint element contains all data describing a new geo anchor,
        // so intialize a new dictionary to collect all of the anchor's data.
        if elementName.lowercased() == "wpt" {
            parsedSpeakerData = attributeDict
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        let tag = elementName.lowercased()
        switch tag {
        case "wpt":
            speakersFoundInFile.append(
                Speaker(parsedSpeakerData)
            )
        default:
            // For elements other than waypoints, save their content in the dictionary.
            parsedSpeakerData[tag] = currentElementText.trimmingCharacters(in: .whitespacesAndNewlines)
            currentElementText = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentElementText += string
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        delegate?.parser(self, didFinishParsingFileWithAnchors: speakersFoundInFile)
    }
}
