# Pagy configuration
# See https://ddnexus.github.io/pagy/

# Default items per page
Pagy::DEFAULT[:limit] = 40

# Handle out-of-range page requests gracefully
require 'pagy/extras/overflow'
Pagy::DEFAULT[:overflow] = :last_page
