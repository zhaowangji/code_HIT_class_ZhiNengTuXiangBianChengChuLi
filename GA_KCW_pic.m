%num2bin---bin2num处理一下前导0
%用new_bin来记录带前导0的用于cross


% GA with KCW for pic

clc,clf,clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% bin=get_num2bin(5);
% 
% bin=zeros(1,8);
% bin(5)=1;bin(6)=0;bin(7)=1;bin(8)=1;
% num=get_bin2num(bin);
% 
% bin=get_num2bin(5);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Ip=imread('coins.png');
[hist]=my_hist(Ip);

population=input('population:');
[group,value]=init__(population,hist);

generation=input('generation:');
cross_rate=100-input('cross_rate:(%)');
mutation_rate=100-input('mutation_rate:(%)');
size_population=length(get_num2bin(population));

mean=0;
% delta=1/population;
mean_delta=1e-5;
variance=0;
variance_delta=1e-5;
% fprintf("%f",delta);
% fprintf("1");
for i=1:generation
    group=generate_new(group,value,population,hist);
    group=cross(group,population,size_population,cross_rate);
    group=mutation(group,population,size_population,mutation_rate);
    
    % fprintf("1");
    mean_now=0;
    for j=1:population
        mean_now=mean_now+group(j);
    end
    mean_now=mean_now/population;
    fprintf("%d %f %f\n",i,mean,mean_now);

    for j=1:population
        variance=variance+(group(j)-mean_now)^2;
    end
    variance=variance/population;

    if abs(mean-mean_now)<mean_delta && variance<variance_delta
    return;
    end

    if i==1
        mean=mean_now;
        continue;
    else 
        mean=mean_now;
    end
    
    for j=1:population
        fprintf("%d %d %d \n",i,j,group(j));
    end


    % if mod(i,5)==0
    %     for j=1:population
    %         fprintf("%d %d %d \n",i,j,group(j));
    %     end
    % end



end

function [group]=mutation(group,population,size_population,mutation_rate)
    for i=1:population
        tmp=rand;
        if 100*tmp>mutation_rate
            num=group(i);
            pos=round(rand*7-0.5)+1;
            bin=get_num2bin(num);
            if bin(pos)==1
                bin(pos)=0;
            else
                bin(pos)=1;
            end
            num=get_bin2num(bin);
            group(i)=num;
        end
    end
end

function [group]=cross(group,population,size_population,cross_rate)
    cross_pair=0;
    for i=1:2:population
        tmp=rand;
        if 100*tmp>=cross_rate
            cross_pair=cross_pair+1;
        end
    end

    for i=1:cross_pair
        num1=round(rand*population-0.5)+1;
        num2=round(rand*population-0.5)+1;

        cross_size=round(rand*size_population);

        bin1=get_num2bin(group(num1));
        bin2=get_num2bin(group(num2));

        for j=size_population:-1:size_population-cross_size+1
            tmp=bin2(j);
            bin2(j)=bin1(j);
            bin1(j)=tmp;
        end

        group(num1)=get_bin2num(bin1);
        group(num2)=get_bin2num(bin2);

    end

end

function [num]=get_bin2num(bin)
    num=0;
    cnt=0;
    % len=length(bin);
    for i=8:-1:1
        num=num+pow2(cnt)*bin(i);
        cnt=cnt+1;
    end
    % fprintf("%d",num);
end

function [real_bin]=get_num2bin(num)
    num_now=num;
    cnt=0;
    bin=zeros(1,8);
    if num==0
        real_bin=zeros(1,8);
        return;
    end

    while num_now>0
        cnt=cnt+1;
        bin(cnt)=mod(num_now,2);
        num_now=floor(num_now/2);
    end
    
    len=length(bin);
    real_bin=zeros(1,len);
    for i=len:-1:1
        real_bin(len-i+1)=bin(i);
    end
    if len<8
       real_bin=[zeros(1,8-len),real_bin]; 
    end

    % rlen=length(real_bin);
    % fprintf("%d:",num);
    % for i=1:rlen
    %     fprintf("%d",real_bin(i));
    % end
    
    % for i=1:8
    %     fprintf("%d",real_bin(i));
    % end

end

% for i=1:population
%     fprintf("%d %d %f\n",i,group(i),value(i));
% end

function [new_group,new_value]=generate_new(group,value,population,hist)

    %calculate the portion of each
    total_value=0;
    for i=1:population
        total_value=total_value+value(i);
    end
    for i=1:population
        portion_value(i)=value(i)/total_value;
    end

    %choose
    prob=rand(1,population);
    for i=1:population
        prob_now=0;
        for j=1:population
            prob_now=prob_now+portion_value(j);
            if prob_now>=prob(i)
                new_group(i)=group(j);
                new_value(i)=calculate_H(hist,new_group(i));
                break;
            end
        end
    end

end

function [group,value]=init__(population,hist)
    %create
    group=round(rand(1,population)*255);
    for i=1:population
        value(i)=calculate_H(hist,group(i));
    end
    
end

function [H]=calculate_H(list,t)

    minl=1;maxl=length(list);
    
    for i=minl:maxl
        if list(i)==0
            list(i)=1e-9;
        end
    end

    pb=0;po=0;
    Htb=0;Hto=0;
    Hb=0;Ho=0;

    for i=minl:t
        pb=pb+list(i);
        Htb=Htb-list(i)*log2(list(i));
    end

    for i=t+1:maxl
        po=po+list(i);
        Hto=Hto-list(i)*log2(list(i));
    end

    if po==0
        Ho=0;
        Hb=log2(pb)+Htb/pb;
    elseif pb==0
        Hb=0;
        Ho=log2(po)+Hto/po;
    else 
        Ho=log2(po)+Hto/po;
        Hb=log2(pb)+Htb/pb;
    end

    H=Ho+Hb;

end

function [N]=my_hist(I)
    row=size(I,1);
    column=size(I,2);
    N=zeros(1,256);
    for i=1:row
        for j=1:column
            k=I(i,j);
            N(k+1)=N(k+1)+1;
        end
    end
end