#!/bin/bash

# Очистка старых секретов задеплоенных helm (Альтернатива HELM_MAX_HISTORY)

RELEASES=$(kubectl get secrets -A -l owner=helm -o jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.metadata.labels.name}{"\n"}{end}' | sort | uniq -c)

while IFS= read -r RELEASE
do
    COUNT=$(awk '{print $1}' <<<"$RELEASE")
    RELEASE_NS=$(awk '{print $2}' <<<"$RELEASE")
    RELEASE_NAME=$(awk '{print $3}' <<<"$RELEASE")

    if (( COUNT > 2 ))
    then
        echo "Count of of versions for release $RELEASE_NAME in namespace $RELEASE_NS is greater than 2, then deleting all but 2 last"
        OLD_VERSIONS=$(kubectl get secrets -n "$RELEASE_NS" -l owner=helm,name="$RELEASE_NAME" -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' --sort-by=.metadata.creationTimestamp | head -n -2 | tr '\n' ' ')
        kubectl -n "$RELEASE_NS"  delete secrets $OLD_VERSIONS
    fi
done <<< "$RELEASES"