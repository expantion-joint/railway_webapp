#!/bin/bash
certbot renew --quiet && nginx -s reload
