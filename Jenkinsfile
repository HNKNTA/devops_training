def GIT_URL = 'https://github.com/HNKNTA/devops_training.git'
def GIT_BRANCH = 'task4'
def GIT_COMMIT_MESSAGE = 'bump build version'
def BUILD_GIT_NAME = 'Jenkins'
def BUILD_GIT_EMAIL = 'hnknta@gmail.com'
def NEXUS_REPO_PATH = 'http://172.18.0.7:8081/nexus/content/repositories/training/'
def MAIN_VERSION_PROP_NAME = 'theVersion'
def BUILD_VERSION_PROP_NAME = 'theBuildVersion'


node('gradle_node') {
    def __MUST_GIT_PUSH = false
    
    stage('Get repo from GitHub.') {
        get_git_repo(GIT_URL, GIT_BRANCH)
        stage('Checking for changes in git.') {
            if (!currentBuild.rawBuild.changeSets.isEmpty()) {
                for(changeSet in currentBuild.rawBuild.changeSets[0]) {
                    def comment = changeSet.getComment()
                    if (!comment.startsWith(GIT_COMMIT_MESSAGE)) {
                        println('must PUSH into Git')
                        __MUST_GIT_PUSH = true
                        break
                    }
                }
            }
            if (__MUST_GIT_PUSH) {
                println('incrementBuildVersion')
                sh './gradlew incrementBuildVersion'
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
                sh "git push ${url} ${GIT_BRANCH} --tags"
            }
        }
    }

    def properties = readProperties file: 'gradle.properties'
    def mainVerstion = properties[MAIN_VERSION_PROP_NAME]
    def buildVerstion = properties[BUILD_VERSION_PROP_NAME]

    def version = mainVerstion + '.' + buildVerstion

    stage('Send the artifact to the Nexus repo.') {
        withCredentials([usernameColonPassword(credentialsId: 'd8adaa74-bec3-4ea4-a0ff-bc49bfc8d758', 
                         variable: 'nexus_creditnails')]) {
            def url = "${NEXUS_REPO_PATH}${GIT_BRANCH}/${mainVerstion}.${buildVerstion}/"
            sh "curl -X PUT -u ${nexus_creditnails} -T ./build/libs/${GIT_BRANCH}.war ${url}"
            
            deploy(url + "${GIT_BRANCH}.war", mainVerstion, buildVerstion)
        }
    }

    node('msi') {
        stage('Build docker image.') {
            build_docker_image(GIT_URL, GIT_BRANCH, version)
        }
    }

    node('mini-comp') {
        stage('Docker image check.') {
            def image_name = "172.16.32.1:5000/${GIT_BRANCH}:${version}"
            def container_name = 'deploy_test'
            def VERSION_CHECK_STR = "v${mainVerstion} build ${buildVerstion}"

            try {
                sh "docker pull ${image_name}"
                sh "docker run -d --name=${container_name} -p 8080:8080 ${image_name}"

                sleep(10)

                if (check_deploy("172.16.32.6:8080/${GIT_BRANCH}", VERSION_CHECK_STR)) {
                    println("Deploy is OK.")
                }
                else {
                    error("Deploy failed on docker container.")
                } 
            }
            finally {
                sh "docker stop ${container_name}"
                sh "docker rm ${container_name}"
            }
        }
    }
}


def deploy(url,  mainVerstion, buildVerstion) {
    def TOMCAT_WEBAPP_DIR = '/usr/local/tomcat/webapps/'
    def HTTPD_IP = '172.18.0.2'
    def PROJECT_MOUNT = 'task4'
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
            if (check_deploy("${tomcat_ip}/${PROJECT_MOUNT}", VERSION_CHECK_STR)) {
                println("Starting LB for tomcat${i}")
                httpRequest "http://${HTTPD_IP}/jk-status?cmd=update&from=list&w=lb&sw=tomcat${i}&vwa=0"
            }
            else {
                error("Deploy failed on tomcat${i}")
            }
        }
    }
}

def check_deploy(uri, value) {
    def response = httpRequest "http://${uri}/"
    return response.content.contains(value)
}

def get_git_repo(url, branch) {
    git branch: branch, url: url
}

def build_docker_image(git_url, git_branch, version) {
    get_git_repo(git_url, git_branch)
    def registry = 'localhost:5000/'
    def tag = "${git_branch}:${version}"
    sh "docker build --build-arg version=${version} --build-arg project_name=${git_branch} -t ${tag} ."
    sh "docker tag ${tag} ${registry}${tag}"
    sh "docker push ${registry}${tag}"
}
