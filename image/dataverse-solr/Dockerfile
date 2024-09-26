FROM ekoindarto/solr-cvm
USER root

COPY entrypoint.sh /rudi-entrypoint.sh

# Owner
RUN chown -R solr:solr /tmp \
    && chmod a+x /tmp/entrypoint.sh

ADD log4j-1.2-api-2.17.0.jar /opt/solr-8.5.2/server/lib/ext/
ADD log4j-core-2.17.0.jar /opt/solr-8.5.2/server/lib/ext/
ADD log4j-web-2.17.0.jar /opt/solr-8.5.2/server/lib/ext/
ADD log4j-api-2.17.0.jar /opt/solr-8.5.2/server/lib/ext/
ADD log4j-slf4j-impl-2.17.0.jar /opt/solr-8.5.2/server/lib/ext/

RUN rm /opt/solr-8.5.2/server/lib/ext/log4j-*-2.11.2.jar \
    && chmod -R a+r /opt/solr-8.5.2/server/lib/ext/

ADD log4j-core-2.17.0.jar /opt/solr-8.5.2/contrib/prometheus-exporter/lib/
ADD log4j-web-2.17.0.jar /opt/solr-8.5.2/contrib/prometheus-exporter/lib/
ADD log4j-slf4j-impl-2.17.0.jar /opt/solr-8.5.2/contrib/prometheus-exporter/lib/

RUN rm /opt/solr-8.5.2/contrib/prometheus-exporter/lib/log4j-*-2.11.2.jar \
    && chmod -R a+r /opt/solr-8.5.2/contrib/prometheus-exporter/lib/

# Ready !
USER solr
CMD ["/rudi-entrypoint.sh"]
