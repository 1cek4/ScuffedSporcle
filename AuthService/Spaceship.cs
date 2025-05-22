using System.ComponentModel.DataAnnotations;

public class ClassicQuiz 
{
    [Key]
    public Guid SpaceshipUUID { get; set; }

    [Required]
    public Guid OrderGuid { get; set; }

    [Required]
    public Order Order { get; set; }

    [Required]
    public string Manufacturer { get; set; }

    [Required]
    public string Name { get; set; }

    [Required]
    public string Version { get; set; }

    [Required]
    public float Wingspan { get; set; }

    [Required]
    public float Price { get; set; }

    [Required]
    public DateTime DateManufactured { get; set; }
}