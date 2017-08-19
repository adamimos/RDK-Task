hostname = char( getHostName( java.net.InetAddress.getLocalHost ) );
box.hostname = char( getHostName( java.net.InetAddress.getLocalHost ) );

if strcmp(hostname,'Behavior0')
    box.box_num = 0;
    box.com_port = 'COM3';
    box.screen_num = 1;
elseif strcmp(hostname,'Behavior1')
    box.box_num = 1;
    box.com_port = 'COM3';
    box.screen_num = 2;
elseif strcmp(hostname,'Behavior2')
    box.box_num = 2;
    box.com_port = 'COM10';
    box.screen_num = 1;
elseif strcmp(hostname,'Behavior3')
    box.box_num = 3;
    box.com_port = 'COM4';
    box.screen_num = 1;
end


save(['C:\DATA\box_' hostname '.mat'],'box')