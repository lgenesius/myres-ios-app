import UIKit
import CoreML

class ImageClassifier {
    static let shared = ImageClassifier()
    private var config: MLModelConfiguration
    
    init() {
        config = MLModelConfiguration()
    }
    
    func analyzeImageCategory(image: UIImage?) -> String {
        guard let buffer = image?.resize(size: CGSize(width: 224, height: 224))?.getCVPixelBuffer() else {
            return "none"
        }
        
        do {
            let model = try GoogLeNetPlaces(configuration: config)
            let input = GoogLeNetPlacesInput(sceneImage: buffer)
            
            let output = try model.prediction(input: input)
            let text = output.sceneLabel
            let category = getImageCategory(input: text)
            return category
        } catch {
            print("Error while analyzing image category: ", error.localizedDescription)
        }
        
        return "none"
    }
    
    private func getImageCategory(input: String) -> String {
        let dict = PhotoCategory.photoCategoryDict
        var category = ""
        
        for (key, value) in dict {
            if value.contains(input) {
                category = key
                break
            }
        }
        
        return category.isEmpty ? "none" : category
    }
}
