{ region, accessKeyId, ... }: {
  "allow-monitoring-collection-${region}" = { nodes, resources, lib, ... }:
    let monitoringSourceIp = resources.elasticIPs.monitoring-ip;
    in {
      inherit region accessKeyId;
      _file = ./allow-monitoring-collection.nix;
      description = "Monitoring collection";
      rules = lib.optionals (nodes ? "monitoring") map (p:
        {
          protocol = "tcp";
          fromPort = p;
          toPort = p; # prometheus exporters
          sourceIp = monitoringSourceIp;
        }) ([
          9100 # prometheus exporters
          9102 # statd exporter
          9113 # nginx exporter
        ] ++ lib.unique (lib.concatMap
          (n: n.config.services.monitoring-exporters.extraPrometheusExportersPorts)
          (lib.attrValues nodes)
        ));
    };
}
