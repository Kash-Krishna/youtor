class Shark:
    """ Sharks //users of SharkByte
    Attributtes:
    
    username:
    sub_list:

    """
    def __init__(self, user_name):
        self.user_name = user_name
        self.sub_list = [] #list of other users the current user is subscribe to
        self.group_tag = [] #same as subs, but for tracker/friend groups
        self.torre_list = []
        return

    def __eq__(self, other):
        return self.user_name == other.user_name
    
    def scream(self):
        print "username: " + self.username
        return

    def follow_the_shark(self, other):
        if other not in self.sub_list:
            self.sub_list.append(other)
        return
