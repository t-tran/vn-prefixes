#!/bin/bash

IPINFO_VN=https://ipinfo.io/countries/vn

# listing all ASNs in Vietnam
curl -s "$IPINFO_VN" | grep '<td class="p-3"><a href="/AS' | sed -e 's/<[^<>]*>//g' -e 's/^[ \t]*//g' > asn.txt

# remove old data
for f in v4.txt v6.txt v4-aggregated.txt v6-aggregated.txt; do
  echo > $f
done

# getting data
for asn in $(cat asn.txt); do
  echo "$(date) : Querying whois to retrieve prefixes for $asn"
  whois -h whois.radb.net -- "-i origin $asn" > ".$asn.whois"
  cat ".$asn.whois" | grep '^route:' | sed -e 's/^route:[ \t]*//g' >> v4.txt
  cat ".$asn.whois" | grep '^route6:' | sed -e 's/^route6:[ \t]*//g' >> v6.txt
  rm -rf ".$asn.whois"
done

echo "$(date) : Aggregating v4"
cat v4.txt | aggregate-prefixes > v4-aggregated.txt
echo "$(date) : Aggregating v6"
cat v6.txt | aggregate-prefixes > v6-aggregated.txt
