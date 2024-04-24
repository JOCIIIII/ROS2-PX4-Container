import rclpy
from sensor_msgs.msg import Image
import airsim
import numpy as np
from cv_bridge import CvBridge
from functools import partial

def main():
    # Initialize ROS node
    rclpy.init()

    # Create a ROS 2 node
    node = rclpy.create_node('image_pub_depth')

    # Initialize AirSim client
    client = airsim.CarClient()
    client.confirmConnection()

    # Create a publisher for the depth image
    left_img_pub = node.create_publisher(Image, 'depth/raw', 10)

    # Create a CvBridge for image conversion
    bridge_d = CvBridge()

    # Create a rate object for publishing frequency
    rate = 30.0  # 30 Hz
    timer_period = 1.0 / rate
    timer_callback = partial(publish_depth_image, client, left_img_pub, bridge_d)
    timer = node.create_timer(timer_period, timer_callback)

    rclpy.spin(node)

    # Clean up when the node is destroyed
    node.destroy_node()
    rclpy.shutdown()

def publish_depth_image(client, left_img_pub, bridge_d):
    # Capture depth image from AirSim
    responses = client.simGetImages([airsim.ImageRequest("DptCamera", airsim.ImageType.DepthPerspective, True, False)])
    
    if len(responses) == 0:
        # No image data received, fill with random values
        depth_img_in_meters = np.random.uniform(low=0.0, high=10.0, size=(480, 640)).astype(np.float32)
    else:
        response = responses[0]
        
        try:
            depth_img_in_meters = airsim.list_to_2d_float_array(response.image_data_float, 480, 640)
        except ValueError:
            print("Error processing depth image data. Filling with random values.")
            depth_img_in_meters = np.random.uniform(low=0.0, high=10.0, size=(480, 640)).astype(np.float32)
        
        # Check for NaN and Inf
        if np.isnan(depth_img_in_meters).any() or np.isinf(depth_img_in_meters).any():
            depth_img_in_meters = np.ones((480, 640), dtype=np.float32) * 50.0
        
    depth_8bit_lerped = depth_img_in_meters.reshape(480, 640, 1)
    
    # Create an Image message
    left_img_msg = Image()
    left_img_msg.header.frame_id = 'depth_image'
    left_img_msg.header.stamp = rclpy.time.Time().to_msg()
    left_img_msg.height = depth_8bit_lerped.shape[0]
    left_img_msg.width = depth_8bit_lerped.shape[1]
    left_img_msg.encoding = "32FC1"
    left_img_msg.is_bigendian = 0
    left_img_msg.step = left_img_msg.width * 4
    
    # Convert and publish the message
    left_img_msg.data = depth_8bit_lerped.tobytes()
    left_img_pub.publish(left_img_msg)

if __name__ == '__main__':
    main()
