package tools;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import com.google.gson.Gson;
import com.google.gson.JsonObject;

import cartago.Artifact;
import cartago.OPERATION;
import cartago.OpFeedbackParam;

public class WeatherStation extends Artifact {

    private static String WEATHER_ENDPOINT = "https://api.open-meteo.com/v1/forecast";

    @OPERATION
    public void readCurrentTemperature(Object latitude, Object longitude, OpFeedbackParam<Double> temperature) {
        String endpoint = WEATHER_ENDPOINT 
            + "?latitude=" +  String.valueOf(latitude) 
            + "&longitude=" + String.valueOf(longitude)
            + "&current_weather=true";
        
        try {
            URI uri = new URI(endpoint);
            
            HttpRequest request = HttpRequest.newBuilder()
                .uri(uri)
                .GET()
                .build();
             
            HttpClient client = HttpClient.newHttpClient();
            try {
                System.out.println(request.toString());
                HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
                if (response.statusCode() != 200) {
                    throw new RuntimeException("HTTP error code : " + response.statusCode());
                }
                String responseBody = response.body();
                JsonObject jsonObject = new Gson().fromJson(responseBody, JsonObject.class);
                Double temperatureValue = jsonObject.getAsJsonObject("current_weather").getAsJsonPrimitive("temperature").getAsDouble();
                System.out.print(temperatureValue);
                temperature.set(temperatureValue);
            } catch (IOException e) {
                e.printStackTrace();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        } catch (URISyntaxException e) {
            e.printStackTrace();
        }

    }
    
}
