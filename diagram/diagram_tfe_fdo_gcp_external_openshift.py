from diagrams import Cluster, Diagram
from diagrams.onprem.compute import Server


from diagrams.gcp.compute import ComputeEngine
from diagrams.gcp.database import SQL, Memorystore
from diagrams.gcp.storage import Filestore
from diagrams.generic.os  import RedHat


# Variables
title = "VPC with 1 public subnet for the openshift environment \nservices subnet for PostgreSQL and Redis"
outformat = "png"
filename = "diagram_tfe_fdo_gcp_external_openshift"
direction = "TB"


with Diagram(
    name=title,
    direction=direction,
    filename=filename,
    outformat=outformat,
) as diag:
    # Non Clustered
    user = Server("user")

    # Cluster 
    with Cluster("gcp"):
        with Cluster("vpc"):
          with Cluster("subnet_public1"):
            OpenShift = RedHat("OpenShift")
          with Cluster("subnet_services"):
            postgresql = SQL("PostgreSQL database")
            redis = Memorystore("Redis")
        bucket = Filestore("TFE bucket")   
               
    # Diagram

    user >> OpenShift >> [postgresql,
                                 bucket,
                                 redis]
   
diag
