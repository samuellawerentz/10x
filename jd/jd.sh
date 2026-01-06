#!/bin/bash

# Jenkins Deploy Script
# Triggers Jenkins builds for contacto projects

JENKINS_URL="https://jenkins.plivops.com"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if credentials are set
if [ -z "$JENKINS_USER" ] || [ -z "$JENKINS_TOKEN" ]; then
    echo -e "${RED}Error: JENKINS_USER and JENKINS_TOKEN environment variables must be set${NC}"
    echo ""
    echo "Set them in your shell profile:"
    echo "  export JENKINS_USER='your-username'"
    echo "  export JENKINS_TOKEN='your-api-token'"
    echo ""
    echo "Get your API token from: $JENKINS_URL (User → Configure → API Token)"
    exit 1
fi

# Function to show usage
usage() {
    echo "Usage: jd [REPO] [BRANCH] [OPTIONS]"
    echo ""
    echo "Arguments:"
    echo "  REPO      Repository name (default: contacto-console)"
    echo "  BRANCH    Branch name (default: dev)"
    echo ""
    echo "Options:"
    echo "  --prod           Deploy to production"
    echo "  -w               Watch build progress"
    echo "  -s               Show build status (recent builds)"
    echo "  -a BUILD_NUMBER  Abort specified build"
    echo "  -i               Interactive mode (select repo and branch with fzf)"
    echo "  -h               Show this help message"
    echo ""
    echo "Examples:"
    echo "  jd                              # Build contacto-console dev, deploy to dev"
    echo "  jd contacto-console dev --prod  # Deploy to prod"
    echo "  jd contacto-api staging -w      # Build contacto-api staging and watch"
    echo "  jd -s                           # Show recent build status"
    echo "  jd -a 3390                      # Abort build #3390 (contacto-console dev)"
    echo "  jd hodor dev -a 123             # Abort build #123 on hodor/dev"
    echo "  jd -i                           # Interactive mode with fzf"
    exit 0
}

# Function to show build status
show_status() {
    local repo=$1
    local branch=$2
    
    echo -e "${YELLOW}Fetching build status for $repo/$branch...${NC}"
    echo ""
    
    # Fetch recent builds with details using depth parameter
    BUILD_DATA=$(curl -s "$JENKINS_URL/job/contacto-io/job/$repo/job/$branch/api/json?depth=1" \
        --user "$JENKINS_USER:$JENKINS_TOKEN")
    
    # Check if we got valid data
    if [ -z "$BUILD_DATA" ]; then
        echo -e "${RED}Failed to fetch build data (empty response)${NC}"
        return 1
    fi
    
    # Parse and display recent builds
    echo "$BUILD_DATA" | python3 -c "
import sys, json
from datetime import datetime

try:
    data = json.load(sys.stdin)
except json.JSONDecodeError as e:
    print('Error parsing JSON:', e)
    sys.exit(1)

builds = data.get('builds', [])[:10]  # Show last 10 builds

if not builds:
    print('No builds found')
    sys.exit(0)

# Header
print('{:<8} {:<20} {:<12} {:<20} {:<15}'.format('Build', 'Status', 'Duration', 'Timestamp', 'Started By'))
print('-' * 85)

for build in builds:
    num = build.get('number', 'N/A')
    result = build.get('result')
    if result is None:
        result = 'IN PROGRESS' if build.get('building', False) else 'UNKNOWN'
    
    duration = build.get('duration', 0)
    timestamp = build.get('timestamp', 0)
    
    # Extract username from actions
    username = '-'
    actions = build.get('actions', [])
    if actions:
        for action in actions:
            if action and isinstance(action, dict) and 'causes' in action:
                for cause in action.get('causes', []):
                    if isinstance(cause, dict) and 'userName' in cause:
                        username = cause['userName']
                        break
                    elif isinstance(cause, dict) and 'userId' in cause:
                        username = cause['userId']
                        break
                if username != '-':
                    break
    
    # Format duration
    if duration > 0:
        duration_str = '{}m {}s'.format(duration // 1000 // 60, (duration // 1000) % 60)
    else:
        duration_str = '-'
    
    # Format timestamp
    if timestamp > 0:
        dt = datetime.fromtimestamp(timestamp / 1000)
        time_str = dt.strftime('%Y-%m-%d %H:%M:%S')
    else:
        time_str = '-'
    
    # Color code status
    if result == 'SUCCESS':
        status = '\033[0;32m✓ SUCCESS\033[0m'
    elif result == 'FAILURE':
        status = '\033[0;31m✗ FAILURE\033[0m'
    elif result == 'ABORTED':
        status = '\033[1;33m⊘ ABORTED\033[0m'
    elif result == 'IN PROGRESS':
        status = '\033[1;33m⟳ IN PROGRESS\033[0m'
    else:
        status = result
    
    print('#{:<7} {:<29} {:<12} {:<20} {}'.format(num, status, duration_str, time_str, username))
"
    
    echo ""
    echo "View all builds: $JENKINS_URL/job/contacto-io/job/$repo/job/$branch"
}

# Function to get repos from Jenkins
get_repos() {
    curl -s "$JENKINS_URL/job/contacto-io/api/json" \
        --user "$JENKINS_USER:$JENKINS_TOKEN" | \
        grep -o '"name":"[^"]*"' | \
        cut -d'"' -f4 | \
        grep -v "^_"
}

# Function to get branches for a repo
get_branches() {
    local repo=$1
    curl -s "$JENKINS_URL/job/contacto-io/job/$repo/api/json" \
        --user "$JENKINS_USER:$JENKINS_TOKEN" | \
        grep -o '"name":"[^"]*"' | \
        cut -d'"' -f4 | \
        grep -v "^_"
}

# Function to abort a build
abort_build() {
    local repo=$1
    local branch=$2
    local build_number=$3
    
    if [ -z "$build_number" ]; then
        echo -e "${RED}Error: Build number is required for abort${NC}"
        echo "Usage: jd [REPO] [BRANCH] -a BUILD_NUMBER"
        exit 1
    fi
    
    echo -e "${YELLOW}Aborting build #$build_number on $repo/$branch...${NC}"
    
    ABORT_URL="$JENKINS_URL/job/contacto-io/job/$repo/job/$branch/$build_number/stop"
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$ABORT_URL" \
        --user "$JENKINS_USER:$JENKINS_TOKEN" 2>&1)
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    
    if [ "$HTTP_CODE" = "302" ] || [ "$HTTP_CODE" = "200" ]; then
        echo -e "${GREEN}✓ Build #$build_number aborted successfully${NC}"
        echo ""
        echo "View build: $JENKINS_URL/job/contacto-io/job/$repo/job/$branch/$build_number"
    else
        echo -e "${RED}✗ Failed to abort build (HTTP $HTTP_CODE)${NC}"
        echo "$RESPONSE" | sed '$d'
        exit 1
    fi
}

# Defaults
REPO="contacto-console"
BRANCH="dev"
DEPLOY_PROD="false"
WATCH="false"
INTERACTIVE="false"
STATUS="false"
ABORT="false"
BUILD_NUMBER=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        --prod)
            DEPLOY_PROD="true"
            shift
            ;;
        -w|--watch)
            WATCH="true"
            shift
            ;;
        -s|--status)
            STATUS="true"
            shift
            ;;
        -a|--abort)
            ABORT="true"
            if [ -n "$2" ] && [[ "$2" =~ ^[0-9]+$ ]]; then
                BUILD_NUMBER="$2"
                shift 2
            else
                echo -e "${RED}Error: -a requires a build number${NC}"
                echo "Usage: jd [REPO] [BRANCH] -a BUILD_NUMBER"
                exit 1
            fi
            ;;
        -i|--interactive)
            INTERACTIVE="true"
            shift
            ;;
        *)
            if [ -z "$REPO_SET" ]; then
                REPO="$1"
                REPO_SET="true"
                shift
            elif [ -z "$BRANCH_SET" ]; then
                BRANCH="$1"
                BRANCH_SET="true"
                shift
            else
                echo -e "${RED}Unknown option: $1${NC}"
                echo "Run 'jd -h' for usage information"
                exit 1
            fi
            ;;
    esac
done

# Abort mode - abort build and exit
if [ "$ABORT" = "true" ]; then
    abort_build "$REPO" "$BRANCH" "$BUILD_NUMBER"
    exit 0
fi

# Status mode - just show status and exit
if [ "$STATUS" = "true" ]; then
    # Handle interactive mode for status
    if [ "$INTERACTIVE" = "true" ]; then
        if ! command -v fzf &> /dev/null; then
            echo -e "${RED}Error: fzf is not installed${NC}"
            echo "Install with: brew install fzf"
            exit 1
        fi
        
        echo -e "${YELLOW}Fetching repositories...${NC}"
        REPO=$(get_repos | fzf --prompt="Select repo: " --height=40% --reverse)
        
        if [ -z "$REPO" ]; then
            echo -e "${RED}No repo selected${NC}"
            exit 1
        fi
        
        echo -e "${YELLOW}Fetching branches for $REPO...${NC}"
        BRANCH=$(get_branches "$REPO" | fzf --prompt="Select branch: " --height=40% --reverse)
        
        if [ -z "$BRANCH" ]; then
            echo -e "${RED}No branch selected${NC}"
            exit 1
        fi
    fi
    
    show_status "$REPO" "$BRANCH"
    exit 0
fi

# Interactive mode with fzf
if [ "$INTERACTIVE" = "true" ]; then
    if ! command -v fzf &> /dev/null; then
        echo -e "${RED}Error: fzf is not installed${NC}"
        echo "Install with: brew install fzf"
        exit 1
    fi
    
    echo -e "${YELLOW}Fetching repositories...${NC}"
    REPO=$(get_repos | fzf --prompt="Select repo: " --height=40% --reverse)
    
    if [ -z "$REPO" ]; then
        echo -e "${RED}No repo selected${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Fetching branches for $REPO...${NC}"
    BRANCH=$(get_branches "$REPO" | fzf --prompt="Select branch: " --height=40% --reverse)
    
    if [ -z "$BRANCH" ]; then
        echo -e "${RED}No branch selected${NC}"
        exit 1
    fi
fi

# Build job path
JOB_PATH="job/contacto-io/job/$REPO/job/$BRANCH"

# Build parameters - always build and postDeploy
PARAMS="build=true&postDeploy=true"

# Set deployment target - explicitly set both to ensure only one is true
if [ "$DEPLOY_PROD" = "true" ]; then
    PARAMS="$PARAMS&deployProd=true&deployDev=false&deployStaging=false"
    DEPLOY_TARGET="prod"
else
    PARAMS="$PARAMS&deployDev=true&deployProd=false&deployStaging=false"
    DEPLOY_TARGET="dev"
fi

# Explicitly disable other optional parameters to ensure they don't run
PARAMS="$PARAMS&debug=false&qa=false&smokeTests=false&overrideDevVersion=false&overrideStagingVersion=false"

# Show what we're doing
echo -e "${YELLOW}Triggering Jenkins build:${NC}"
echo "  Repo: $REPO"
echo "  Branch: $BRANCH"
echo "  Deploy to: $DEPLOY_TARGET"
echo ""

# Trigger the build
BUILD_URL="$JENKINS_URL/$JOB_PATH/buildWithParameters"
RESPONSE=$(curl -s -i -X POST "$BUILD_URL" \
    --user "$JENKINS_USER:$JENKINS_TOKEN" \
    --data "$PARAMS" 2>&1)

HTTP_CODE=$(echo "$RESPONSE" | grep "^HTTP" | tail -n1 | awk '{print $2}')

if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓ Build triggered successfully${NC}"
    echo ""
    echo "View build at: $JENKINS_URL/$JOB_PATH"
    
    if [ "$WATCH" = "true" ]; then
        echo ""
        
        # Try to get queue location from response headers
        QUEUE_LOCATION=$(echo "$RESPONSE" | grep -i "^Location:" | awk '{print $2}' | tr -d '\r')
        
        if [ -n "$QUEUE_LOCATION" ]; then
            echo -e "${YELLOW}Build queued, waiting for it to start...${NC}"
            
            # Poll queue until we get a build number
            BUILD_NUMBER=""
            for i in {1..30}; do
                QUEUE_INFO=$(curl -s "${QUEUE_LOCATION}api/json" --user "$JENKINS_USER:$JENKINS_TOKEN")
                BUILD_NUMBER=$(echo "$QUEUE_INFO" | grep -o '"number":[0-9]*' | head -1 | cut -d':' -f2)
                
                if [ -n "$BUILD_NUMBER" ]; then
                    break
                fi
                
                echo -n "."
                sleep 1
            done
            echo ""
        fi
        
        # Fallback: get next build number
        if [ -z "$BUILD_NUMBER" ]; then
            echo -e "${YELLOW}Fetching build number...${NC}"
            sleep 2
            BUILD_INFO=$(curl -s "$JENKINS_URL/$JOB_PATH/lastBuild/api/json" \
                --user "$JENKINS_USER:$JENKINS_TOKEN")
            BUILD_NUMBER=$(echo "$BUILD_INFO" | grep -o '"number":[0-9]*' | head -1 | cut -d':' -f2)
        fi
        
        if [ -n "$BUILD_NUMBER" ]; then
            echo -e "${GREEN}Following build #$BUILD_NUMBER${NC}"
            echo ""
            
            # Stream console output with progressive text API
            CONSOLE_URL="$JENKINS_URL/$JOB_PATH/$BUILD_NUMBER/logText/progressiveText"
            START=0
            
            while true; do
                RESPONSE=$(curl -s -D - "$CONSOLE_URL?start=$START" \
                    --user "$JENKINS_USER:$JENKINS_TOKEN")
                
                # Get X-Text-Size header for next start position
                NEW_START=$(echo "$RESPONSE" | grep -i "^X-Text-Size:" | awk '{print $2}' | tr -d '\r')
                
                # Get X-More-Data header to check if build is still running
                MORE_DATA=$(echo "$RESPONSE" | grep -i "^X-More-Data:" | awk '{print $2}' | tr -d '\r')
                
                # Extract body (skip headers)
                OUTPUT=$(echo "$RESPONSE" | sed '1,/^\r$/d')
                
                # Print new output
                if [ -n "$OUTPUT" ]; then
                    echo -n "$OUTPUT"
                fi
                
                # Update start position for next request
                if [ -n "$NEW_START" ]; then
                    START=$NEW_START
                fi
                
                # Check if build is complete (X-More-Data: false means complete)
                if [ "$MORE_DATA" = "false" ]; then
                    echo ""
                    echo -e "${GREEN}Build completed${NC}"
                    break
                fi
                
                sleep 2
            done
        else
            echo -e "${RED}Could not determine build number${NC}"
        fi
    fi
else
    echo -e "${RED}✗ Build trigger failed (HTTP $HTTP_CODE)${NC}"
    echo "$RESPONSE"
    exit 1
fi
