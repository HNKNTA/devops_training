def GIT_URL = 'https://github.com/HNKNTA/devops_training.git'
def GIT_BRANCH = 'task3'
def GIT_COMMIT_MESSAGE = 'bump build version'
def BUILD_GIT_NAME = 'Jenkins'
def BUILD_GIT_EMAIL = 'hnknta@gmail.com'
def NEXUS_REPO_PATH = 'http://172.18.0.7:8081/nexus/content/repositories/training/'
def MAIN_VERSION_PROP_NAME = 'theVersion'
def BUILD_VERSION_PROP_NAME = 'theBuildVersion'


node('gradle_node') {
    def __MUST_GIT_PUSH = false
    
    stage('Get repo from GitHub.') {
        git branch: GIT_BRANCH, url: GIT_URL
        stage('Checking for changes in git.') {
            println(currentBuild.rawBuild.changeSets)
            println(currentBuild.rawBuild.changeSets.properties)
            for(changeSetList in currentBuild.rawBuild.changeSets){
                for(changeSet in changeSetList) {
                    println(changeSet.getComment());
                }
            }
            
            if (!currentBuild.rawBuild.changeSets.isEmpty()) {
                try {
                    def comment = currentBuild.rawBuild.changeSets[0].get(0).getComment()
                    if (!comment.equals(GIT_COMMIT_MESSAGE)) {
                        sh './gradlew incrementBuildVersion'
                        __MUST_GIT_PUSH = true
                    }
                }
                catch (Exception e) {
                    __MUST_GIT_PUSH = false
                }
            }
        }

    }
    stage('Build project.') {
        sh './gradlew build'
    }
    
    if (__MUST_GIT_PUSH) {
        stage('Pushing build version to git.') {
            withCredentials([usernameColonPassword(credentialsId: 'aa78ca40-8198-4fcd-a2c7-cb769d8dce4f', 
                             variable: 'git_creditnails')]) {
                sh "git config user.name '${BUILD_GIT_NAME}'"
                sh "git config user.email '${BUILD_GIT_EMAIL}'"
                sh 'git config push.default simple'
                sh 'git add gradle.properties'
                sh "git commit -m '${GIT_COMMIT_MESSAGE}'"
                def url = GIT_URL.replace('://', "://${git_creditnails}@")
                sh "git push ${url} task3 --tags"
            }
        }
    }

    stage('Send the artifact to the Nexus repo.') {
        withCredentials([usernameColonPassword(credentialsId: 'd8adaa74-bec3-4ea4-a0ff-bc49bfc8d758', 
                         variable: 'nexus_creditnails')]) {
            def properties = readProperties file: 'gradle.properties'
            def mainVerstion = properties[MAIN_VERSION_PROP_NAME]
            def buildVerstion = properties[BUILD_VERSION_PROP_NAME]
            def url = "${NEXUS_REPO_PATH}${GIT_BRANCH}/${mainVerstion}.${buildVerstion}/"
            sh "curl -X PUT -u ${nexus_creditnails} -T ./build/libs/${GIT_BRANCH}.war ${url}"
            
            deploy(url + "${GIT_BRANCH}.war", mainVerstion, buildVerstion)
        }
    }
}

def deploy(url,  mainVerstion, buildVerstion) {
    def TOMCAT_WEBAPP_DIR = '/usr/local/tomcat/webapps/'
    def HTTPD_IP = '172.18.0.2'
    def PROJECT_MOUNT = 'task3'
    def VERSION_CHECK_STR = "v${mainVerstion} build ${buildVerstion}"
    def TOMCATS_IP = [
        'tomcat1' : '172.18.0.3:8080',
        'tomcat2' : '172.18.0.4:8080',
        ];

    stage('Deploy the war to tomcats.')
    node('msi') {
        for(i = 1; i <= 2; i++) {
            println("Stopping LB for tomcat${i}")
            httpRequest "http://${HTTPD_IP}/jk-status?cmd=update&from=list&w=lb&sw=tomcat${i}&vwa=1"
            sh "docker exec -u root task3_tomcat${i} wget ${url} -N -P ${TOMCAT_WEBAPP_DIR}"
            println('Waiting...')
            sleep(10)
            println('Check if version updated.')
            def tomcat_ip = TOMCATS_IP["tomcat${i}"]
            def response = httpRequest "http://${tomcat_ip}/${PROJECT_MOUNT}/"
            if (response.content.contains(VERSION_CHECK_STR)) {
                println("Starting LB for tomcat${i}")
                httpRequest "http://${HTTPD_IP}/jk-status?cmd=update&from=list&w=lb&sw=tomcat${i}&vwa=0"
            }
            else {
                error("Deploy failed on tomcat${i}")
            }
        }
    }
}

