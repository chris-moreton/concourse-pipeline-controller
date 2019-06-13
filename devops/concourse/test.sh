      if [ "((ENVIRONMENT))" = "prod" ]; then
        echo "  routes:" >> manifest.yml
        echo "    - route: $ROUTE_CF_APPS" >> manifest.yml
        echo "    - route: $ROUTE_WWW" >> manifest.yml
        echo "    - route: $ROUTE_BARE" >> manifest.yml
      else
        echo "  routes:" >> manifest.yml
        echo "  - route: $ROUTE_CF_APPS" >> manifest.yml
        echo "  - route: $ROUTE_ENV" >> manifest.yml
      fi