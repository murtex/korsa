
	% -----------------------------------------------------------------------
	% DO NOT EDIT ANYTHING HERE!
	% -----------------------------------------------------------------------

	% i/o
rawdir_ = fullfile( datadir_, 'raw/' );
procdir_ = fullfile( datadir_, project_ );
plotdir_ = 'images/';

	% processing
pre_rate_ = 85;
pre_cutoff_ = 25;

pca_method_ = 'inertia';
pca_cycles_ = 1;
pca_spline_ = [5, 4, 3];
pca_tags = {'auto'};

man_filtin_ = {'auto'};
man_filtex_ = {};
man_filtsel_ = {'gest'};
man_brighten_ = 0.1;

movs_q = 0.2;
movs_sub = 100;

	% sensors
sensbplate_ = {'frbp', 'lbp', 'rbp'};
senspalate_ = {'trace'};
sensref_ = {'lear', 'nose', 'rear', 'ui'};

senstongue_ = {'tb', 'tt'};
sensspeech_ = [senstongue_, 'jaw'];

senssag_ = [sensref_, sensspeech_];

sensaudio_ = {'audio'};
sensema_ = [sensbplate_, senspalate_, sensref_, sensspeech_];

	% axes
axvert_ = {'y'};
axpca_ = {'x'};
axsag_ = {'x', 'y'};

axaudio_ = {'ch1'};
axema_ = {'x', 'y', 'z'};

	% filters
trialdims_ = {'sensors', 'axes'};

filtaudio_ = {trialdims_, {sensaudio_, axaudio_}, true};
filtema_ = {trialdims_, {sensema_, axema_}, true};
filtpca_ = {trialdims_, {sensema_, axpca_}, true};

