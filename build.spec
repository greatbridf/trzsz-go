Name: trzsz
Version: 1.2.0
Release: 1%{?dist}

License: MIT
Summary: trzsz

BuildRequires: make
BuildRequires: golang >= 1.25

Source0: %{tarball}

%description

%files
/usr/bin/*

%prep
%autosetup -p 1 -n %{tarname}

%build
%{__make}

%install
%{__make} install DESTDIR=%{buildroot}

%clean
%{__rm} -rf %{buildroot}

%changelog
