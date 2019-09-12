package com.mikele.fariseo.service;

import org.apache.http.HttpHost;
import org.elasticsearch.action.index.IndexRequest;
import org.elasticsearch.action.index.IndexResponse;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.client.RestClient;
import org.elasticsearch.client.RestHighLevelClient;
import org.elasticsearch.common.xcontent.XContentType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.PropertySource;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import java.io.IOException;


@PropertySource("classpath:config.properties")
@Service
public class ElasticSearchMonitorService {

    private static final Logger LOGGER = LoggerFactory.getLogger(ElasticSearchMonitorService.class);

    @Value("${es.host}")
    private String ES_HOST;
    @Value("${es.port.one}")
    private int ES_PORT_ONE;
    @Value("${es.port.two}")
    private int ES_PORT_TWO;
    @Value("${es.channel}")
    private String ES_CHANNEL;


    /**
     * ES Client.
     */
    private RestHighLevelClient client;


    /**
     * Method to construct the ES client when the controller gets constructed.
     */
    @PostConstruct
    public void getConnection() {
        LOGGER.info("Starting ES client connection.");

        this.client = new RestHighLevelClient(RestClient.builder(
                new HttpHost(this.ES_HOST, this.ES_PORT_ONE, this.ES_CHANNEL)
                , new HttpHost(this.ES_HOST, this.ES_PORT_TWO, this.ES_CHANNEL)));

    }

    /**
     * Method to close the REST High level client.
     */
    @PreDestroy
    public void closeConnection() {
        LOGGER.info("Closing ES Connection");
        if (this.client != null) {
            try {
                this.client.close();
            } catch (IOException e) {
            }
        }
    }

    /**
     * Method to store an index a document sync inside ES.
     *
     * @param jsonString to be stored.
     * @param indexName  indexName.
     * @return Generated IndexResponse.
     * @throws IOException thrown if issue while indexing a document.
     */
    public IndexResponse index(final String jsonString, final String indexName) throws IOException {
        LOGGER.info("Indexing " + jsonString + " - documentName " + indexName);
        IndexRequest request = new IndexRequest(indexName);
        request.source(jsonString, XContentType.JSON);
        try {
            return this.client.index(request, RequestOptions.DEFAULT);
        } catch (IOException e) {
            e.printStackTrace();
            LOGGER.error("Error while indexing.", e);
            throw e;
        }
    }


}
