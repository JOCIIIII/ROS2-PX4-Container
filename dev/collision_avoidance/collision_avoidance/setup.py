from setuptools import find_packages, setup

package_name = 'collision_avoidance'

setup(
    name=package_name,
    version='0.1.0',
    packages=find_packages(exclude=['test']),
    data_files=[
        ('share/ament_index/resource_index/packages',
            ['resource/' + package_name]),
        ('share/' + package_name, ['package.xml']),
    ],
    install_requires=['setuptools'],
    zip_safe=True,
    maintainer='kestrel',
    maintainer_email='kestrel@inha.edu',
    description='TODO: Package description',
    license='MIT',
    tests_require=['pytest'],
    entry_points={
        'console_scripts': [
            'collision_avoidance = collision_avoidance.obstacle_avoidance_ros2:main',
            'pub_depth = collision_avoidance.ROS_2_PUB_depth:main',
        ],
    },
)
