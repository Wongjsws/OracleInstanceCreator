#!/bin/bash

# Setup OCI CLI configuration
# This script configures OCI CLI authentication using environment variables

set -euo pipefail

source "$(dirname "$0")/utils.sh"

setup_oci_config() {
    log_info "Setting up OCI configuration..."
    
    # Validate required environment variables
    require_env_var "OCI_USER_OCID"
    require_env_var "OCI_KEY_FINGERPRINT" 
    require_env_var "OCI_TENANCY_OCID"
    require_env_var "OCI_REGION"
    require_env_var "OCI_PRIVATE_KEY"
    
    # Create OCI config directory
    mkdir -p ~/.oci
    
    # Create OCI config file
    # Trim stray whitespace/newlines from copy-pasted secret values: a trailing
    # space or newline on any of these turns into a hard-to-diagnose error deep
    # in the OCI SDK (e.g. region -> "Invalid endpoint host") instead of a clear
    # validation message.
    local user_ocid fingerprint tenancy_ocid region
    user_ocid=$(trim_whitespace "$OCI_USER_OCID")
    fingerprint=$(trim_whitespace "$OCI_KEY_FINGERPRINT")
    tenancy_ocid=$(trim_whitespace "$OCI_TENANCY_OCID")
    region=$(trim_whitespace "$OCI_REGION")

    cat > ~/.oci/config <<EOL
[DEFAULT]
user=${user_ocid}
fingerprint=${fingerprint}
tenancy=${tenancy_ocid}
region=${region}
key_file=${HOME}/.oci/oci_api_key.pem
EOL
    
    chmod 600 ~/.oci/config
    log_info "OCI config file created"
    
    # Create OCI private key file
    echo "${OCI_PRIVATE_KEY}" > ~/.oci/oci_api_key.pem
    chmod 600 ~/.oci/oci_api_key.pem
    log_info "OCI private key file created"
    
    log_success "OCI configuration completed successfully"
}

# Setup proxy configuration
setup_proxy_config() {
    log_info "Setting up proxy configuration..."
    parse_and_configure_proxy false
}

# Run setup if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_oci_config
    setup_proxy_config
fi