package com.mikele.fariseo.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mikele.fariseo.service.ElasticSearchMonitorService;
import org.elasticsearch.action.index.IndexResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.net.URLDecoder;

@RestController
@RequestMapping("/fariseo/")
public class NetworksMonitorController {


    private static final Logger LOGGER = LoggerFactory.getLogger(NetworksMonitorController.class);

    @Autowired
    private ElasticSearchMonitorService elasticSearchMonitorService;


    public static final String FARISEO_INDEX = "fariseo_endpoint_statuses";

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


    @RequestMapping(value = "/monitor/events/", method = RequestMethod.POST)
    public @ResponseBody
    ResponseEntity<String> registerMonitorEvents(@RequestBody final String encodedJsonEvents) {

        try {
            String stringJsonEvents = URLDecoder.decode(encodedJsonEvents, "UTF-8").trim();

            //Removes the char '=' if at sometime got added to the jsonEvent.
            if (stringJsonEvents.endsWith("=")) {
                stringJsonEvents = stringJsonEvents.substring(0, stringJsonEvents.length() - 1);
            }

            ObjectMapper mapper = new ObjectMapper();
            JsonNode jsonEvents = mapper.readTree(stringJsonEvents);
            jsonEvents.get("events").iterator().forEachRemaining(eventNode -> {
                try {
                    LOGGER.info("Indexing \n" + eventNode.toString() + "\n");
                    IndexResponse result = this.elasticSearchMonitorService.index(eventNode.toString(), this.FARISEO_INDEX);
                    LOGGER.info("RESULT=" + result.getResult().name());
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
            });

            return new ResponseEntity<>("{result:'SUCCESS'}\n", HttpStatus.OK);
        } catch (IOException e) {
            e.printStackTrace();
            return new ResponseEntity<>("{result:'ERROR'}\n", HttpStatus.BAD_REQUEST);
        }
    }


}