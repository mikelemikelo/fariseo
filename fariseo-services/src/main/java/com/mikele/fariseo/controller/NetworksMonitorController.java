package com.mikele.fariseo.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;

@RestController
@RequestMapping("/fariseo/")
public class NetworksMonitorController {


    private static final Logger LOGGER = LoggerFactory.getLogger(NetworksMonitorController.class);

    /**
     * Method to validate that REST entpoints are up and running.
     *
     * @return String confirmation that RESTEndpoints are up and running.
     */
    @RequestMapping(value = "/", method = RequestMethod.GET)
    public @ResponseBody
    ResponseEntity<String> validate() {
        return new ResponseEntity<>("Fariseo is up and running", HttpStatus.OK);
    }


    @RequestMapping(value = "/monitor/event/", method = RequestMethod.POST)
    public @ResponseBody
    ResponseEntity<String> registerMonitorEvent(@RequestBody final String encodedJsonEvent) {
        LOGGER.debug("input:" + encodedJsonEvent);
        LOGGER.info("input:" + encodedJsonEvent);
        
        ObjectMapper objectMapper = new ObjectMapper();

        try {

            String jsonEvent = URLDecoder.decode(encodedJsonEvent, "UTF-8").trim();

            //Removes the char '=' if at sometime got added to the jsonEvent.
            if (jsonEvent.endsWith("=")) {
                jsonEvent = jsonEvent.substring(0, jsonEvent.length() - 1);
            }




            System.out.println("jsonEvent=" + jsonEvent);

        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        return new ResponseEntity<>("{result:'SUCCESS'}\n", HttpStatus.OK);
    }


}