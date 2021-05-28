

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}
struct WeatherManager{
    let WeatherUrl = "https://api.openweathermap.org/data/2.5/weather?&appid=\(Constants.apiKey)&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather (cityName: String){
        let urlString = "\(WeatherUrl)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather (latitude: Double, longitude: Double){
        let urlString = "\(WeatherUrl)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    func performRequest(with urlString: String){
        if let url = URL(string: urlString){
            
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data{
                    if let weather = self.parseJSON(safeData){
                    
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    func parseJSON(_ weatherData: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let name = decodedData.name
            let temp = decodedData.main.temp
            let id = decodedData.weather[0].id
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
        }catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
        
    }
    
}
