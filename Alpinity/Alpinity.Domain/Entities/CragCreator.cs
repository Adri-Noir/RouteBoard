using System;

namespace Alpinity.Domain.Entities;

public class CragCreator
{
    public Guid CragId { get; set; }
    public Crag Crag { get; set; }

    public Guid UserId { get; set; }
    public User User { get; set; }
}