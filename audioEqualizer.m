close all; clear all; clc;

file = uigetfile; %browse to choose the signal you want
[Signal,sampleRate] = audioread(file);  %read the signal
fprintf('Audio Sample Rate: %d\n',sampleRate);
gain = [];
titles={'170','170-310','310-600','600-1000','1000-3000','3000-6000','6000-12000','12000-14000','14000-16000'};
%titles is array of strings that contain Frequency bands

for i = 1:9
    str=sprintf('Please enter gain of (%s)Hz in dB: ',titles{i});
    gain(i) = str2double(input(str,'s'));
    %str2double convert string to double if it isn't a number it will give nan
    while(isnan(gain(i)))
        str=sprintf('Error try again!! Please enter gain of (%s)Hz in dB: ',titles{i});
        gain(i)=str2double(input(str,'s')); %used to check if the input is correct or not
    end
    gain(i)=db2mag(gain(i)); %converting db to magnitude
end

newFs=str2double(input('\nPlease enter output sample rate (must be in range 80-1000000): ','s'));
while(newFs==0 || newFs<=80 || newFs>=1000000 || isnan(newFs)) %validating output sampling rate
    newFs=str2double(input('Invalid input! Please enter output sample rate: ','s'));
end

type = str2double(input('\nPlease enter type of filter (1.FIR / 2.IIR): ','s'));
while((type~=1 && type~=2) || isnan(type)) %validating filter type
    type = str2double(input('Invalid input!Please enter type of filter (1.FIR / 2.IIR): ','s'));
end

tempFs=48000;  %sampling rate greater than 2*Fm
%To ensure when normalizing frequency that normalized frequencies between 0 and 1 "exclusive"
%where 16000Hz is largest frequency band in the given bands
Y=resample(Signal,tempFs,sampleRate);%Resampling Signal so that if user entered an audio with low Fs the filtering will work
Fs=tempFs;


Fn=Fs/2;
%Normalizing frequency bands
wn1=170/Fn;
wn2=[170 310]/Fn;
wn3=[310 600]/Fn;
wn4=[600 1000]/Fn;
wn5=[1000 3000]/Fn;
wn6=[3000 6000]/Fn;
wn7=[6000 12000]/Fn;
wn8=[12000 14000]/Fn;
wn9=[14000 16000]/Fn;

ytot = 0; %Output signal after adding all filtered signals
ytot_gain = 0;%Output signal after adding all filtered signals multiplied by gain

if(type==1) %FIR filter
    order=100; %It is better to use high order with FIR
    for i=1:9
        if(i==1)
            num=fir1(order,wn1,'low');%Low pass filter
        elseif(i==2)
            num=fir1(order,wn2,'bandpass');%Band pass filter
        elseif(i==3)
            num=fir1(order,wn3,'bandpass');%Band pass filter
        elseif(i==4)
            num=fir1(order,wn4,'bandpass');%Band pass filter
        elseif(i==5)
            num=fir1(order,wn5,'bandpass');%Band pass filter
        elseif(i==6)
            num=fir1(order,wn6,'bandpass');%Band pass filter
        elseif(i==7)
            num=fir1(order,wn7,'bandpass');%Band pass filter
        elseif(i==8)
            num=fir1(order,wn8,'bandpass');%Band pass filter
        else
            num=fir1(order,wn9,'bandpass');%Band pass filter
        end
        den=1; %No poles in FIR filter
        y=filter(num,1,Y); %Filtering input signal
        ytot=ytot+y; %Adding filtered signals
        ytot_gain=ytot_gain+gain(i)*y; %Adding filtered signals and multiplying by gain
        figure('units','normalized','outerposition',[0 0 1 1]);
        freqz(num,den);title(sprintf('(FIR) Magnitude and Phase for (%s)Hz',titles{i}));%figure;%plotting magnitude and phase (normalized)
        figure('units','normalized','outerposition',[0 0 1 1]);
        
        [h,t] = impz(num,den); %impulse response
        subplot(2,3,1); stem(t,h); title(sprintf('(FIR) Impulse Response for (%s)Hz',titles{i}));
        
        [s,t] = stepz(num,den); %step response
        subplot(2,3,2); stem(t,s); title(sprintf('(FIR) Step response for (%s)Hz',titles{i}));
        
        fprintf('\n(FIR) Order for (%s)Hz = %d\n',titles{i} ,order);
        TF = tf(num,den); %Using TF to find gain
        [zero1, gains] = zero(TF); %gain
        fprintf('(FIR) Gain for (%s)Hz = %d\n\n',titles{i} ,gains);
        t=linspace(0,length(y)/Fs,length(y));f=linspace(-Fs/2,Fs/2,length(y));
        subplot(2,3,3);zplane(roots(num),roots(den));title(sprintf('(FIR) Zero-Pole plot (%s)Hz',titles{i}));
        %plotting zeros and poles
        subplot(2,3,4); plot(t,y); title(sprintf('(FIR) Filtered input in Time Domain for (%s)Hz',titles{i}));
        subplot(2,3,5); plot(f,abs(fftshift(fft(y)))); title(sprintf('(FIR) Filtered input in Freq Domain for (%s)Hz',titles{i}));
    end
    
else %IIR filter
    for i=1:9
        order=2; %It is better to use high order with IIR (to make graphs clear)
        if(i==1)
            [num,den]=butter(order,wn1,'low');%Low pass filter
            [z,p,k] = butter(order,wn1,'low');
        elseif(i==2)
            [num,den]=butter(order,wn2,'bandpass');%Band pass filter
            [z,p,k] = butter(order,wn2,'bandpass');
        elseif(i==3)
            [num,den]=butter(order,wn3,'bandpass');%Band pass filter
            [z,p,k] = butter(order,wn3,'bandpass');
        elseif(i==4)
            [num,den]=butter(order,wn4,'bandpass');%Band pass filter
            [z,p,k] = butter(order,wn4,'bandpass');
        elseif(i==5)
            [num,den]=butter(order,wn5,'bandpass');%Band pass filter
            [z,p,k] = butter(order,wn5,'bandpass');
        elseif(i==6)
            [num,den]=butter(order,wn6,'bandpass');%Band pass filter
            [z,p,k] = butter(order,wn6,'bandpass');
        elseif(i==7)
            [num,den]=butter(order,wn7,'bandpass');%Band pass filter
            [z,p,k] = butter(order,wn7,'bandpass');
        elseif(i==8)
            [num,den]=butter(order,wn8,'bandpass');%Band pass filter
            [z,p,k] = butter(order,wn8,'bandpass');
        else
            [num,den]=butter(order,wn9,'bandpass');%Band pass filter
            [z,p,k] = butter(order,wn9,'bandpass');
        end
        y = filter(num,den,Y); %Filtering input signal
        ytot=ytot+y; %Adding filtered signals
        ytot_gain=ytot_gain+gain(i)*y; %Adding filtered signals and multiplying by gain
        
        figure('units','normalized','outerposition',[0 0 1 1]);freqz(num,den); title(sprintf('(IIR) Magnitude and Phase for (%s)Hz',titles{i}));
        figure('units','normalized','outerposition',[0 0 1 1]);
        [h,t] = impz(num,den); %Impulse response
        subplot(2,3,1); stem(t,h); title(sprintf('(IIR) Impulse Response for (%s)Hz',titles{i}));
        
        [s,t] = stepz(num,den); %Step response
        subplot(2,3,2); stem(t,s);title(sprintf('(IIR) Step response (%s)Hz',titles{i}));
        
        fprintf('(IIR) Order for (%s)Hz = %d\n',titles{i}, order);
        
        subplot(2,3,3);zplane(z,p); title(sprintf('(IIR) Zero-Pole plot %s',titles{i}));
        t=linspace(0,length(y)/Fs,length(y));f=linspace(-Fs/2,Fs/2,length(y));
        fprintf('(IIR) Gain for (%s)Hz= %d\n\n', titles{i},k);
        subplot(2,3,4); plot(t,y); title(sprintf('(IIR) Filtered input in Time Domain for (%s)Hz',titles{i}));
        subplot(2,3,5); plot(f,abs(fftshift(fft(y)))); title(sprintf('(IIR) Filtered input in Freq Domain for (%s)Hz',titles{i}));
    end
end

tSignal=linspace(0,length(Signal)/sampleRate,length(Signal)); %to plot input signal in time domain
fSignal=linspace(-sampleRate/2,sampleRate/2,length(Signal));
ytot_gain=resample(ytot_gain,newFs,tempFs); %Resampling to output sample rate "newFs"

tCompositeSignal=linspace(0,length(ytot_gain)/newFs,length(ytot_gain)); %to plot composite signal in time domain
fCompositeSignal=linspace(-newFs/2,newFs/2,length(ytot_gain));
figure('units','normalized','outerposition',[0 0 1 1]);
subplot(2,2,1); plot(tSignal,Signal); title('Input signal in Time Domain');
subplot(2,2,2); plot(fSignal,abs(fftshift(fft(Signal)))); title('Input Signal in Freq Domain');

subplot(2,2,3); plot(tCompositeSignal,ytot_gain); title('Composite signal in Time Domain');
subplot(2,2,4); plot(fCompositeSignal,abs(fftshift(fft(ytot_gain)))); title('Composite Signal in Freq Domain');

sound(ytot_gain,newFs); %play composite sound with newFs