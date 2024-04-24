#! /bin/bash

debug_message() {
    echo "
        ____  __________  __  ________   __  _______  ____  ______
       / __ \/ ____/ __ )/ / / / ____/  /  |/  / __ \/ __ \/ ____/
      / / / / __/ / __  / / / / / __   / /|_/ / / / / / / / __/   
     / /_/ / /___/ /_/ / /_/ / /_/ /  / /  / / /_/ / /_/ / /___   
    /_____/_____/_____/\____/\____/  /_/  /_/\____/_____/_____/   
    
    "
    echo "INFO [SITL] DEBUG_MODE IS SET. NOTHING WILL RUN"
}


# A. DEBUG MODE / SIMULATION SELCTOR
## CASE A-1: DEBUG MODE
if [ "${DEBUG_MODE}" -eq "1" ]; then

    debug_message

    ## A-1. EXPORT ENVIRONMENT VARIABLE?
    ### CASE A-1-1: YES EXPORT THEM
    if [ "${EXPORT_ENV}" -eq "1" ]; then
        if [ "${REBUILD_MODE}" -eq "1" ]; then

        cd ${HOME}/ros_ws 
        colcon build --symlink-install
        source /home/user/ros_ws/install/setup.bash
	
        fi
        # PLACE YOUR ENVIRONMENT VARIABLE TO BE SET HERE
        # # - GET LINE NUMBER TO START ADDING export STATEMENT
        # COMMENT_BASH_START=$(grep -c "" /home/user/.bashrc)
        # COMMENT_ZSH_START=$(grep -c "" /home/user/.zshrc)

        # COMMENT_BASH_START=$(($COMMENT_BASH_START + 1))
        # COMMENT_ZSH_START=$(($COMMENT_ZSH_START + 1))


        # #- WTIE VARIABLED TO BE EXPORTED TO THE TEMPFILE
        # echo "DEBUG_MODE=0" >> /tmp/envvar
        # echo "GZ_SIM_RESOURCE_PATH=${GZ_SIM_RESOURCE_PATH}" >> /tmp/envvar

        # #- ADD VARIABLES TO BE EXPORTED TO SHELL RC
        # for value in $(cat /tmp/envvar)
        # do
        #     echo ${value} >> /home/user/.bashrc
        #     echo ${value} >> /home/user/.zshrc
        # done

        # #- ADD export STATEMENT TO VARIABLES
        # sed -i "${COMMENT_BASH_START},\$s/\(.*\)/export \1/g" \
        #     ${HOME}/.bashrc
        # sed -i "${COMMENT_ZSH_START},\$s/\(.*\)/export \1/g" \
        #     ${HOME}/.zshrc

        # #- REMOVE TEMPORARY FILE
        # rm -f /tmp/envvar

        echo "INFO [SITL] NO ENVIRONMENT VRIABLE TO BE SET"

    ### CASE A-1-2: NO LEAVE THEM CLEAN
    else
        echo "INFO [SITL] ENVIRONMENT VARS WILL NOT BE SET"
    fi

## CASE A-2: SIMULATION MODE
else
    source /home/user/px4_ros_ws/install/setup.bash
    source /home/user/ros_ws/install/setup.bash

    if [ "${ROS2_ALGORITHM}" == "PATH_PLANNING" ]; then

        ros2 run pathplanning Plan2WP

    elif [ "${ROS2_ALGORITHM}" == "PATH_FOLLOWING" ]; then
        mkdir -p /home/user/log/point_mass_6d/datalogfile
        ros2 run pathfollowing node_att_ctrl &
        ros2 run pathfollowing node_MPPI_output &

    elif [ "${ROS2_ALGORITHM}" == "CONTROLLER" ]; then

        ros2 run controller controller

    elif [ "${ROS2_ALGORITHM}" == "COLLISION_AVOIDANCE" ]; then

        ros2 run collision_avoidance collision_avoidance
    else
        echo "INFO ROS2_ALGORITHM NAME NOT BE SET"
    fi

fi

# KEEP CONTAINER ALIVE
sleep infinity
