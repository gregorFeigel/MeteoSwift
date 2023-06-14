# MeteoSwift

Collection of meteorology routines ported to swift. <br/>
Comming soon.

> **Note:** 
> This project is currently under development. Don't expect things to be documented or everything to work.
> APIs will probably change in future.


### Generic Meterological Converter
This converter converts datasets from on convention to another. <br/>
For example, if the dataset conforms to the CF-Convention, the source convention should be set to `CFConvention()`. The target convention can be any user-defined convention that follows the `Convention` protocol. 
Each convention has its own generic variable and type constraints such as `.air_temperature: TemperatureUnit.kelvin` and a name mapping function `.air_temperature = "temperature"`. These information are then used to build a converter that even can convert data concurrently.<br/>
Custom units following the `MeteoUnit` protocol can be implemented. 
