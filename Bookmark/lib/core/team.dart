class TeamMember {
  final String name;
  final String studentId;
  final String role;
  final String? photo;
  const TeamMember(this.name, this.studentId, this.role, {this.photo});
}

class TeamConfig {
  static const teamName = 'Bookmark';

  static const members = [
    TeamMember('นาย ณพกร พระสุข', '016840641011-3', 'ผู้พัฒนา',
        photo: 'assets/team/member1.JPG'),
    TeamMember('นาย พัชรธร จันทะ', '016840641012-1', 'ผู้ออกแบบ',
        photo: 'assets/team/member2.JPG'),
  ];
}
