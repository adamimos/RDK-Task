hostname = char( getHostName( java.net.InetAddress.getLocalHost ) );

box.box_num = 0;
box.com_port = 'COM3';
box.hostname = char( getHostName( java.net.InetAddress.getLocalHost ) );
box.screen_num = 1;

save(['C:\DATA\box_' hostname '.mat'],'box')