# ReactiveWeatherExample
A simple iOS weather app using the MVVM pattern and RxSwift framework.

#How it works
The MVVMViewController only binds it's properties to the ones in MVVMViewModel.
There's a UITextField in the ViewController which sents a searchText property in the ViewModel once it's changed. The ViewModel then iniates a JSON request for weather data from openweathermap.org, and creates a new Weather object, which acts as the model.

Once the Weather object is set, properties in the ViewModel are set accordingly. Since outlets in the ViewController are bound to properties in the ViewModel, they get set automatically.